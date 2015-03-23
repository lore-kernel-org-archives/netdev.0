From: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Subject: RE: Bug in drivers/net/ethernet/freescale/fec_main.c, TX is broken.
 In 4.0.0-rc3
Date: Mon, 23 Mar 2015 02:42:52 +0000
Message-ID: <BLUPR03MB373FC71B9A8559E51084C26F50D0@BLUPR03MB373.namprd03.prod.outlook.com>
References: <390621425930628@web28o.yandex.ru>
	<3625951426018334@web26j.yandex.ru>
	<BLUPR03MB373A446E2D97992CA7AAA32F5020@BLUPR03MB373.namprd03.prod.outlook.com>
	<726281426513068@web10o.yandex.ru>
	<BLUPR03MB3739B9C6E14A106CCAEBA32F5020@BLUPR03MB373.namprd03.prod.outlook.com>
	<994171426532944@web7m.yandex.ru>
	<20150321205359.GM8656@n2100.arm.linux.org.uk>
 <CAOMZO5BnPQTFoBRr4EGH24_yZZAY6NJmVFg4WeiJcTqrYqki5A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: =?utf-8?B?0J/QsNC90L7QsiDQkNC90LTRgNC10Lk=?= <rockford@yandex.ru>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Fabio Estevam <festevam@gmail.com>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0147.outbound.protection.outlook.com ([207.46.100.147]:48320
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752124AbbCWCmz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Mar 2015 22:42:55 -0400
In-Reply-To: <CAOMZO5BnPQTFoBRr4EGH24_yZZAY6NJmVFg4WeiJcTqrYqki5A@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRmFiaW8gRXN0ZXZhbSA8ZmVzdGV2YW1AZ21haWwuY29tPiBTZW50OiBTdW5kYXksIE1h
cmNoIDIyLCAyMDE1IDY6MzYgQU0NCj4gVG86IFJ1c3NlbGwgS2luZyAtIEFSTSBMaW51eA0KPiBD
Yzog0J/QsNC90L7QsiDQkNC90LTRgNC10Lk7IER1YW4gRnVnYW5nLUIzODYxMTsgbmV0ZGV2QHZn
ZXIua2VybmVsLm9yZzsgbGludXgtYXJtLQ0KPiBrZXJuZWwNCj4gU3ViamVjdDogUmU6IEJ1ZyBp
biBkcml2ZXJzL25ldC9ldGhlcm5ldC9mcmVlc2NhbGUvZmVjX21haW4uYywgVFggaXMNCj4gYnJv
a2VuLiBJbiA0LjAuMC1yYzMNCj4gDQo+IEhpIFJ1c3NlbGwsDQo+IA0KPiBPbiBTYXQsIE1hciAy
MSwgMjAxNSBhdCA1OjUzIFBNLCBSdXNzZWxsIEtpbmcgLSBBUk0gTGludXgNCj4gPGxpbnV4QGFy
bS5saW51eC5vcmcudWs+IHdyb3RlOg0KPiANCj4gPiBHaXZlbiB0aGF0IHRoaXMgYnVnIGNhbiBz
ZXJpb3VzbHkgc2NyZXcgZGF0YSB1cCBpbiB1bmRldGVjdGFibGUgd2F5cw0KPiA+IChUQ1AgY2hl
Y2tzdW1zIGRvbid0IHNhdmUgeW91LCBiZWNhdXNlIHRoZSBGRUMgZ2VuZXJhdGVzIHRoZW0gb24g
dGhlDQo+ID4gZGF0YSB3aGljaCBpdCByZWFkIGZyb20gbWVtb3J5LCBldmVuIGlmIGl0IGhhcHBl
bmVkIHRvIHJlYWQgdGhlIGRhdGENCj4gPiBmcm9tIHRoZSBTb0MncyBib290IFJPTSkgd2UgZG8g
bmVlZCB0byBnZXQgdGhpcyBmaXhlZCBBU0FQLg0KPiANCj4gQ3VycmVudCBtYWlubGluZSBoYXMg
MmI5OTVmNjM5ODcwMTMgcmV2ZXJ0ZWQsIHNvIDQuMC1yYzUgd2lsbCBub3QgaGF2ZQ0KPiB0aGlz
IGNvcnJ1cHRpb24gcHJvYmxlbS4NCj4gDQo+IFJlZ2FyZHMsDQo+IA0KPiBGYWJpbyBFc3RldmFt
DQoNCldlIGNhbm5vdCByZXZlcnQgdGhlIGNvbW1pdCAyYjk5NWY2Mzk4NzAxMywgb3RoZXJ3aXNl
IHRoZXJlIGludHJvZHVjZSBvdGhlciBpc3N1ZS4gVGhlIGNvcnJlY3QgZml4IG1ldGhvZCBpcyBS
dXNzZWxsIEtpbmcncyBmaXggaW4gdGhlIHByZXZpb3VzIG1haWwuDQpJdCBpcyBzdHJhbmdlIHRo
aW5nIHRoYXQgSSBjYW5ub3QgcmVwcm9kdWNlIHRoZSBpc3N1ZSBvbiBpLk1YNnEgc2FicmVzZCBi
b2FyZC4gQW55d2F5LCB3ZSBtdXN0IGNvbnNpZGVyIFRTTyBjYXNlIHRoYXQgaXQncyBub3QgYSBm
cmFnbWVudGVkIHNrYi4NCg0KUmVnYXJkcywNCkFuZHkNCg==
