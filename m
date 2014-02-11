From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] net: rtnetlink: fix correct size given to memset
Date: Tue, 11 Feb 2014 15:54:10 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6BCE71@AcuExch.aculab.com>
References: <1392127598-3719-1-git-send-email-fx.lebail@yahoo.com>
 <1392132522.6615.85.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: NETDEV <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: 'Eric Dumazet' <eric.dumazet@gmail.com>,
	Francois-Xavier Le Bail <fx.lebail@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:40494 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751065AbaBKPzX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Feb 2014 10:55:23 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 12949-05 for <netdev@vger.kernel.org>;
 Tue, 11 Feb 2014 15:55:20 +0000 (GMT)
In-Reply-To: <1392132522.6615.85.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyBEdW1hemV0DQo+IE9uIFR1ZSwgMjAxNC0wMi0xMSBhdCAxNTowNiArMDEwMCwg
RnJhbmNvaXMtWGF2aWVyIExlIEJhaWwgd3JvdGU6DQo+ID4gRmluZCBieSBjcHBjaGVjazoNCj4g
PiBbbmV0L2NvcmUvcnRuZXRsaW5rLmM6MTg0Ml06ICh3YXJuaW5nKSBVc2luZyBzaXplIG9mIHBv
aW50ZXIgbGlua2luZm8gaW5zdGVhZCBvZiBzaXplIG9mIGl0cyBkYXRhLg0KPiA+DQo+ID4gU2ln
bmVkLW9mZi1ieTogRnJhbmNvaXMtWGF2aWVyIExlIEJhaWwgPGZ4LmxlYmFpbEB5YWhvby5jb20+
DQo+ID4gLS0tDQo+ID4NCj4gPiBUaGUgZGlhZ25vc2lzIG9mIGNwcGNoZWNrIHNlZW1zIHJlbGV2
YW50Lg0KPiA+DQo+ID4gIG5ldC9jb3JlL3J0bmV0bGluay5jIHwgICAgMiArLQ0KPiA+ICAxIGZp
bGUgY2hhbmdlZCwgMSBpbnNlcnRpb24oKyksIDEgZGVsZXRpb24oLSkNCj4gPg0KPiA+IGRpZmYg
LS1naXQgYS9uZXQvY29yZS9ydG5ldGxpbmsuYyBiL25ldC9jb3JlL3J0bmV0bGluay5jDQo+ID4g
aW5kZXggMDQ4ZGM4ZC4uOWE1ZGJmMSAxMDA2NDQNCj4gPiAtLS0gYS9uZXQvY29yZS9ydG5ldGxp
bmsuYw0KPiA+ICsrKyBiL25ldC9jb3JlL3J0bmV0bGluay5jDQo+ID4gQEAgLTE4MzksNyArMTgz
OSw3IEBAIHJlcGxheToNCj4gPiAgCQlpZiAoZXJyIDwgMCkNCj4gPiAgCQkJcmV0dXJuIGVycjsN
Cj4gPiAgCX0gZWxzZQ0KPiA+IC0JCW1lbXNldChsaW5raW5mbywgMCwgc2l6ZW9mKGxpbmtpbmZv
KSk7DQo+ID4gKwkJbWVtc2V0KGxpbmtpbmZvLCAwLCBzaXplb2YoKmxpbmtpbmZvKSk7DQo+ID4N
Cj4gPiAgCWlmIChsaW5raW5mb1tJRkxBX0lORk9fS0lORF0pIHsNCj4gPiAgCQlubGFfc3RybGNw
eShraW5kLCBsaW5raW5mb1tJRkxBX0lORk9fS0lORF0sIHNpemVvZihraW5kKSk7DQo+IA0KPiAN
Cj4gVGhpcyBpcyBhYnNvbHV0ZWx5IHdyb25nLg0KPiANCj4gCXN0cnVjdCBubGF0dHIgKmxpbmtp
bmZvW0lGTEFfSU5GT19NQVgrMV07DQo+IA0KPiBzaXplb2YobGlua2luZm8pIGlzIHRvdGFsbHkg
YXBwcm9wcmlhdGUNCj4gDQo+IHNpemVvZigqbGlua2luZm8pIGlzIGVxdWFsIHRvIHNpemVvZih2
b2lkICopLCBhbmQgdGhpcyBpcyBub3Qgd2hhdCB3ZQ0KPiBuZWVkIGhlcmUuDQoNCkkgZ3Vlc3Mg
dGhhdCBjaGFuZ2luZyBpdCB0bzoNCgltZW1zZXQoJmxpbmtpbmZvLCAwLCBzaXplb2YobGlua2lu
Zm8pKTsNCg0KbWlnaHQgbWFrZSB0aGUgdG9vbCBoYXBweSwgYnV0IGl0IHJlYWxseSBvdWdodCB0
byBiZSB0YXVnaHQgYWJvdXQgYXJyYXlzLg0KDQoJRGF2aWQNCg0K
