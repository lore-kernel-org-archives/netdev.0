From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2] net: bridge: add compile-time assert for cb struct
 size
Date: Tue, 3 Mar 2015 14:15:52 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CAF3C01@AcuExch.aculab.com>
References: <1425387211-16807-1-git-send-email-fw@strlen.de>
	 <063D6719AE5E284EB5DD2968C1650D6D1CAF3BB7@AcuExch.aculab.com>
 <1425391664.5130.174.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: 'Florian Westphal' <fw@strlen.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Eric Dumazet' <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.184]:61991 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751406AbbCCORM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2015 09:17:12 -0500
In-Reply-To: <1425391664.5130.174.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyBEdW1hemV0IA0KPiBPbiBUdWUsIDIwMTUtMDMtMDMgYXQgMTM6NTAgKzAwMDAs
IERhdmlkIExhaWdodCB3cm90ZToNCj4gPiBGcm9tOiBGbG9yaWFuIFdlc3RwaGFsDQo+ID4gPiBt
YWtlIGJ1aWxkIGZhaWwgaWYgc3RydWN0dXJlIG5vIGxvbmdlciBmaXRzIGludG8gLT5jYiBzdG9y
YWdlLg0KPiA+ID4NCj4gPiA+IFNpZ25lZC1vZmYtYnk6IEZsb3JpYW4gV2VzdHBoYWwgPGZ3QHN0
cmxlbi5kZT4NCj4gPiA+IC0tLQ0KPiA+ID4gIENoYW5nZSBzaW5jZSB2MTogdXNlIEZJRUxEX1NJ
WkVPRg0KPiA+ID4NCj4gPiA+ICBjaGVja3BhdGNoIGNvbXBsYWlucyBhYm91dCA+ODAgY2hhcnMs
IGJ1dCBsaW5lIGJyZWFrIGlzIHVnbHkgaGVyZS4NCj4gPiA+DQo+ID4gPiBkaWZmIC0tZ2l0IGEv
bmV0L2JyaWRnZS9ici5jIGIvbmV0L2JyaWRnZS9ici5jDQo+ID4gPiBpbmRleCBmYjU3YWI2Li4w
MmMyNGNmIDEwMDY0NA0KPiA+ID4gLS0tIGEvbmV0L2JyaWRnZS9ici5jDQo+ID4gPiArKysgYi9u
ZXQvYnJpZGdlL2JyLmMNCj4gPiA+IEBAIC0xOTAsNiArMTkwLDggQEAgc3RhdGljIGludCBfX2lu
aXQgYnJfaW5pdCh2b2lkKQ0KPiA+ID4gIHsNCj4gPiA+ICAJaW50IGVycjsNCj4gPiA+DQo+ID4g
PiArCUJVSUxEX0JVR19PTihzaXplb2Yoc3RydWN0IGJyX2lucHV0X3NrYl9jYikgPiBGSUVMRF9T
SVpFT0Yoc3RydWN0IHNrX2J1ZmYsIGNiKSk7DQo+ID4gPiArDQo+ID4NCj4gPiBXaGF0IGFib3V0
IHVzaW5nIHNvbWV0aGluZyBiYXNlZCBvbjoNCj4gPiAjZGVmaW5lIEdFVF9DQihza2IsIHR5cGUp
ICgodHlwZSAqKSgoc2tiKS0+Y2IgKyAoc2l6ZW9mIChjaGFyWyhzaXplb2YgKHR5cGUpIDw9IHNp
emVvZiAoc2tiLT5jYikpID8gMSA6IC0xXSAtIDEpKSkNCj4gPiB0byBhY2Nlc3Mgc2tiLT5zYj8N
Cj4gPg0KPiA+IFRoZW4gYWxsIGludmFsaWQgdXNlcyBhcmUgbGlrZWx5IHRvIGJlIHBpY2tlZCB1
cC4NCj4gDQo+IFdlIHdhbnQgYSBidWlsZCBlcnJvciwgbm90IGEgcnVudGltZSBvbmUuDQoNClRo
YXQgaXMgYSBidWlsZCBlcnJvci4NCg0KCURhdmlkDQo=
