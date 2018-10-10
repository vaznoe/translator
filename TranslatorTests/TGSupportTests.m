//
//  TGSupportTests.m
//  TranslatorTests
//
//  Created by Tetiana Galushko on 10/5/18.
//  Copyright © 2018 Tatiana Galushko. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "TGSupportLanguage.h"
#import "TGCountry.h"
#import "TGGetLangs.h"

#import "TGCoreDataService.h"
#import "TGSupportResponce.h"
#import "TGTranslatorService.h"


@interface TGSupportTests : XCTestCase <TGTranslatorServiceDelegate>

@end

@implementation TGSupportTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testSupportInit {

    NSDictionary *serverDictionary = @{KeySupportLanguagesDirs: @[@"ru-en", @"ru-pl", @"ru-fr", @"en-ru", @"en-fr"],
                                       KeySupportLanguagesLangs: @{@"ru":@"русский",
                                                                   @"en":@"английский",
                                                                   @"fr":@"французкий",
                                                                   @"pl":@"польский"}};
    TGGetLangs *getLangs = [TGGetLangs new];
    NSArray *inputOutputCodes = serverDictionary[KeySupportLanguagesDirs];
    NSDictionary *langsDictionary = serverDictionary[KeySupportLanguagesLangs];
    
    for (NSString *inputOutputCode in inputOutputCodes) {
        [getLangs addInputOutputCountryCode:inputOutputCode andLangsDictionary:langsDictionary];
    }
    
    
    NSArray *supports = getLangs.supports;
    XCTAssertEqual(supports.count, 2);
    
    for (TGSupportLanguage *support in supports) {
        XCTAssertGreaterThanOrEqual(support.outputCountries.count, 1);
        XCTAssertTrue(support.inputCountry.code.length > 1);
        XCTAssertTrue(support.inputCountry.name.length > 1);
        
        for (TGCountry *country in support.outputCountries) {
            XCTAssertTrue(country.code.length == 2, @"Code: %@", country.code);
            XCTAssertTrue(country.name.length > 2);
        }
    }
}

- (void)testSupportInitAndSaveToCoreData {
    
    NSDictionary *serverDictionary = @{KeySupportLanguagesDirs: @[@"ru-en", @"ru-pl", @"ru-fr", @"en-ru", @"en-fr"],
                                       KeySupportLanguagesLangs: @{@"ru":@"русский",
                                                                   @"en":@"английский",
                                                                   @"fr":@"французкий",
                                                                   @"pl":@"польский"}};
    TGGetLangs *getLangs = [TGGetLangs new];
    NSArray *inputOutputCodes = serverDictionary[KeySupportLanguagesDirs];
    NSDictionary *langsDictionary = serverDictionary[KeySupportLanguagesLangs];
    
    for (NSString *inputOutputCode in inputOutputCodes) {
        [getLangs addInputOutputCountryCode:inputOutputCode andLangsDictionary:langsDictionary];
    }
    
    TGCoreDataService *coreDataService = [TGCoreDataService new];
    [coreDataService saveSupportLanguages:getLangs.supports];
    
    NSArray *inputCountries = [coreDataService getInputCountries];
    XCTAssertEqual(inputCountries.count, 2);
    for (TGCountry *country in inputCountries) {
        XCTAssertTrue(country.code.length >= 2, @"Code: %@", country.code);
        XCTAssertTrue(country.name.length > 2);
    }
    
    NSString *code = [(TGCountry*)inputCountries.firstObject code];
    NSArray *outputCountries = [coreDataService getOutputCountriesWithInputCountryCode:code];
    XCTAssertGreaterThanOrEqual(outputCountries.count, 1);
    for (TGCountry *country in outputCountries) {
        XCTAssertTrue(country.code.length >= 2, @"Code: %@", country.code);
        XCTAssertTrue(country.name.length > 2);
    }
}

- (void)testSupportResponce {
    TGSupportResponce *responce = [[TGSupportResponce alloc] initWithObject:nil andDelegate:self];
    NSDictionary *serverDictionary = @{KeySupportLanguagesDirs: @[@"ru-en", @"ru-pl", @"ru-fr", @"en-ru", @"en-fr"],
                                       KeySupportLanguagesLangs: @{@"ru":@"русский",
                                                                   @"en":@"английский",
                                                                   @"fr":@"французкий",
                                                                   @"pl":@"польский"}};
    NSData *myData = [NSJSONSerialization dataWithJSONObject:serverDictionary options:NSJSONWritingPrettyPrinted error:nil];
    [responce setResponceServiceData:myData andError:nil];
}

-(void)translatorApiService: (TGTranslatorService*) service didSupportLanguages: (NSArray<TGSupportLanguage*>*)supportLanguages {
    XCTAssertTrue(supportLanguages.count == 2);
    
    TGCoreDataService *cDataService = [cDataService getInputCountries];
    NSArray *inputCounties = [cDataService getOutputCountriesWithInputCountryCode:code];
    XCTAssertGreaterThan(outputCountries.count, supportLanguages.count);
    
    for (TGCountry *country in outputCountries) {
        XCTAssertTrue(country.code.length >= 2, @"Code: %@", country.code);
        XCTAssertTrue(country.name.length > 2);
    }
}

-(void)traslatorService: (TGTranslatorService*) servoce didFailWithError: (NSError*) error {
    XCTFail(@"Error: %@", error);
}

@end
