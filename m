From: <Woojung.Huh@microchip.com>
Subject: RE: [PATCH] lan78xx: relocate mdix setting to phy driver
Date: Wed, 16 Nov 2016 15:31:43 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40965E6E@CHN-SV-EXMX02.mchp-main.com>
References: <9235D6609DB808459E95D78E17F2E43D40965635@CHN-SV-EXMX02.mchp-main.com>
 <c894a7bd-4062-cb63-6b70-02bb86c874c1@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: <andrew@lunn.ch>, <netdev@vger.kernel.org>,
        <UNGLinuxDriver@microchip.com>
To: <f.fainelli@gmail.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpout.microchip.com ([198.175.253.82]:34474 "EHLO
        email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752679AbcKPPbp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 10:31:45 -0500
In-Reply-To: <c894a7bd-4062-cb63-6b70-02bb86c874c1@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBzdGF0aWMgdm9pZCBsYW44OHh4X3NldF9tZGl4KHN0cnVjdCBwaHlfZGV2aWNlICpwaHlkZXYp
DQo+IHsNCj4gCWludCBidWY7DQo+IAlpbnQgbWFza192YWw7DQo+IA0KPiAJc3dpdGNoIChwaHlk
ZXYtPm1kaXgpIHsNCj4gCWNhc2UgRVRIX1RQX01ESToNCj4gCQltYXNrX3ZhbCA9IExBTjg4WFhf
RVhUX01PREVfQ1RSTF9NRElfOw0KPiAJCWJyZWFrOw0KPiAJY2FzZSBFVEhfVFBfTURJX1g6DQo+
IAkJbWFza192YWwgPSBMQU44OFhYX0VYVF9NT0RFX0NUUkxfTURJX1hfOw0KPiAJCWJyZWFrOw0K
PiAJY2FzZSBFVEhfVFBfTURJX0FVVE86DQo+IAkJbWFza192YWwgPSBMQU44OFhYX0VYVF9NT0RF
X0NUUkxfQVVUT19NRElYXzoNCj4gCQlicmVhazoNCj4gCWRlZmF1bHQ6DQo+IAkJcmV0dXJuOw0K
PiAJfQ0KPiANCj4gCXBoeV93cml0ZShwaHlkZXYsIExBTjg4WFhfRVhUX1BBR0VfQUNDRVNTLA0K
PiAJCSAgTEFOODhYWF9FWFRfUEFHRV9TUEFDRV8xKTsNCj4gCWJ1ZiA9IHBoeV9yZWFkKHBoeWRl
diwgTEFOODhYWF9FWFRfTU9ERV9DVFJMKTsNCj4gCWJ1ZiAmPSB+TEFOODhYWF9FWFRfTU9ERV9D
VFJMX01ESVhfTUFTS187DQo+IAlidWYgfD0gbWFza192YWw7DQo+IAlwaHlfd3JpdGUocGh5ZGV2
LCBMQU44OFhYX0VYVF9NT0RFX0NUUkwsIGJ1Zik7DQo+IAlwaHlfd3JpdGUocGh5ZGV2LCBMQU44
OFhYX0VYVF9QQUdFX0FDQ0VTUywNCj4gCQkgIExBTjg4WFhfRVhUX1BBR0VfU1BBQ0VfMCk7DQo+
IH0NCkZsb3JpYW4sDQpMb29rcyBzaW1wbGVyIHRvIG1lIHRvby4gV2lsbCBzdWJtaXQgbmV3IHBh
dGNoLg0KDQpUaGFua3MuDQotIFdvb2p1bmcNCg==
