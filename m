From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: RE: [PATCH net-next] bnx2x: Resolving a possible dead-lock
 situation
Date: Tue, 23 Nov 2010 08:36:22 -0800
Message-ID: <8628FE4E7912BF47A96AE7DD7BAC0AADDDEF920549@SJEXCHCCR02.corp.ad.broadcom.com>
References: <1290528912.15453.3.camel@lb-tlvb-vladz>
 <1290529777.3046.99.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: base64
Cc: "Dave Miller" <davem@davemloft.net>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"netdev list" <netdev@vger.kernel.org>
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3259 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754098Ab0KWQg2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Nov 2010 11:36:28 -0500
In-Reply-To: <1290529777.3046.99.camel@edumazet-laptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiANCj4gVGhhdCBzZWVtcyBzdHJhbmdlLiBFdmVuIGlmIHBlcmZvcm1hbmNlIHBlbmFsdHkgaXMg
bm90IG1pbmltYWwsIGl0DQo+IHNob3VsZCBiZSBhdm9pZGVkLg0KPiANCj4gSWYgcHJvYmxlbSBj
b21lcyBmcm9tIGV0aHRvb2wsIHdoeSBub3QgcHJldmVudGluZyBCSCBpbiBldGh0b29sIGl0c2Vs
Zg0KPiA/DQoNCkxvb2tzIGdvb2QuIExldCBtZSBydW4gYSBmZXcgY2hlY2tzIGJlZm9yZSB1IHN1
Ym1pdCBhIHBhdGNoIHRvIERhdmUuIE9yIGRvIHUgcHJlZmVyIA0KbWUgdG8gcHVzaCBpdCBvbiB5
b3VyIGJlaGFsZj8NCg0KVGhhbmtzLA0KdmxhZA0KDQo+IA0KPiBkaWZmIC0tZ2l0IGEvZHJpdmVy
cy9uZXQvYm54MngvYm54MnhfZXRodG9vbC5jDQo+IGIvZHJpdmVycy9uZXQvYm54MngvYm54Mnhf
ZXRodG9vbC5jDQo+IGluZGV4IGQwMmZmYmQuLjFmN2Q0ZTYgMTAwNjQ0DQo+IC0tLSBhL2RyaXZl
cnMvbmV0L2JueDJ4L2JueDJ4X2V0aHRvb2wuYw0KPiArKysgYi9kcml2ZXJzL25ldC9ibngyeC9i
bngyeF9ldGh0b29sLmMNCj4gQEAgLTE0OTksOSArMTQ5OSwxMSBAQCBzdGF0aWMgaW50IGJueDJ4
X3J1bl9sb29wYmFjayhzdHJ1Y3QgYm54MnggKmJwLA0KPiBpbnQgbG9vcGJhY2tfbW9kZSwgdTgg
bGlua191cCkNCj4gIAkgKiB1cGRhdGVzIHRoYXQgaGF2ZSBiZWVuIHBlcmZvcm1lZCB3aGlsZSBp
bnRlcnJ1cHRzIHdlcmUNCj4gIAkgKiBkaXNhYmxlZC4NCj4gIAkgKi8NCj4gLQlpZiAoYnAtPmNv
bW1vbi5pbnRfYmxvY2sgPT0gSU5UX0JMT0NLX0lHVSkNCj4gKwlpZiAoYnAtPmNvbW1vbi5pbnRf
YmxvY2sgPT0gSU5UX0JMT0NLX0lHVSkgew0KPiArCQlsb2NhbF9iaF9kaXNhYmxlKCk7DQo+ICAJ
CWJueDJ4X3R4X2ludChmcF90eCk7DQo+IC0NCj4gKwkJbG9jYWxfYmhfZW5hYmxlKCk7DQo+ICsJ
fQ0KPiAgCXJ4X2lkeCA9IGxlMTZfdG9fY3B1KCpmcF9yeC0+cnhfY29uc19zYik7DQo+ICAJaWYg
KHJ4X2lkeCAhPSByeF9zdGFydF9pZHggKyBudW1fcGt0cykNCj4gIAkJZ290byB0ZXN0X2xvb3Bi
YWNrX2V4aXQ7DQo+IA0KPiANCg0K

