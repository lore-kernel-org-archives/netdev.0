From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: RE: ipgre rss is broken since gro
Date: Mon, 10 Dec 2012 19:20:25 +0000
Message-ID: <504C9EFCA2D0054393414C9CB605C37F1BFC32A1@SJEXCHMB06.corp.ad.broadcom.com>
References: <504C9EFCA2D0054393414C9CB605C37F1BFB80B2@SJEXCHMB06.corp.ad.broadcom.com>
 <504C9EFCA2D0054393414C9CB605C37F1BFB80D8@SJEXCHMB06.corp.ad.broadcom.com>
 <CANn89iKE2RxRBWRuXGwjydQKjPLhPbcoZaJS5rcBKbJWWnL4ZQ@mail.gmail.com>
 <1355018645.3113.0.camel@lb-tlvb-dmitry.il.broadcom.com>
 <1355086161.3113.9.camel@lb-tlvb-dmitry.il.broadcom.com>
 <CANn89iKtWuN=CRn-JBzmmo8jCCJQhZjAT8jA+9dgfmup99O03g@mail.gmail.com>
 <504C9EFCA2D0054393414C9CB605C37F1BFC104B@SJEXCHMB06.corp.ad.broadcom.com>
 <1355158471.27891.44.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: base64
Cc: "Eric Dumazet" <edumazet@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3628 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750952Ab2LJTUi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Dec 2012 14:20:38 -0500
In-Reply-To: <1355158471.27891.44.camel@edumazet-glaptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBFcmljIER1bWF6ZXQgW21haWx0
bzplcmljLmR1bWF6ZXRAZ21haWwuY29tXQ0KPiBTZW50OiBNb25kYXksIERlY2VtYmVyIDEwLCAy
MDEyIDY6NTUgUE0NCj4gVG86IERtaXRyeSBLcmF2a292DQo+IENjOiBFcmljIER1bWF6ZXQ7IG5l
dGRldkB2Z2VyLmtlcm5lbC5vcmcNCj4gU3ViamVjdDogUkU6IGlwZ3JlIHJzcyBpcyBicm9rZW4g
c2luY2UgZ3JvDQo+IA0KPiBPbiBNb24sIDIwMTItMTItMTAgYXQgMTE6MzIgKzAwMDAsIERtaXRy
eSBLcmF2a292IHdyb3RlOg0KPiANCj4gDQo+IGRyb3BwZWQ6NTE2MTAgIHNvIG9idmlvdXNseSAg
b25lIGNwdSBpcyBmdWxseSBsb2FkZWQuDQpMaW5rIHBhcnRuZXIgY29udGludWVkIHB1c2hpbmcg
ZGF0YSBvdmVybmlnaHQNCg0KPiANCj4gSSBiZWxpZXZlIHBlcmZvcm1hbmNlIHByb2JsZW0gbWln
aHQgY29tZSBmcm9tIHRoZQ0KPiBza2Jfc2V0X3F1ZXVlX21hcHBpbmcoc2tiLCAwKTsgaW4gX19z
a2JfdHVubmVsX3J4KCkNCj4gDQo+IFNvIGFsbCBwYWNrZXRzIGFyZSBxdWV1ZWQgaW50byBhIHNp
bmdsZSBHUk8gcXVldWUsIGluc3RlYWQgb2YgYmVpbmcNCj4gc3BsaXQgYXMgaW50ZW5kZWQgaW4g
bXVsdGlwbGUgcXVldWVzLg0KPiANCj4gSSBjYW50IGZpbmQgd2h5IHdlIG11c3QgY2xlYXIgcXVl
dWVfbWFwcGluZywgc28gY291bGQgeW91IHRyeSA6DQo+IA0KPiANCj4gZGlmZiAtLWdpdCBhL2lu
Y2x1ZGUvbmV0L2RzdC5oIGIvaW5jbHVkZS9uZXQvZHN0LmgNCj4gaW5kZXggOWE3ODgxMC4uNGNi
MjdkZiAxMDA2NDQNCj4gLS0tIGEvaW5jbHVkZS9uZXQvZHN0LmgNCj4gKysrIGIvaW5jbHVkZS9u
ZXQvZHN0LmgNCj4gQEAgLTMyOSw3ICszMjksNiBAQCBzdGF0aWMgaW5saW5lIHZvaWQgX19za2Jf
dHVubmVsX3J4KHN0cnVjdCBza19idWZmICpza2IsDQo+IHN0cnVjdCBuZXRfZGV2aWNlICpkZXYp
DQo+ICAJICovDQo+ICAJaWYgKCFza2ItPmw0X3J4aGFzaCkNCj4gIAkJc2tiLT5yeGhhc2ggPSAw
Ow0KPiAtCXNrYl9zZXRfcXVldWVfbWFwcGluZyhza2IsIDApOw0KPiAgCXNrYl9kc3RfZHJvcChz
a2IpOw0KPiAgCW5mX3Jlc2V0KHNrYik7DQo+ICB9DQo+IA0KWWVwLCB0aGlzIHJlc29sdmVkIHRo
ZSBpc3N1ZSAtIEludGVyZmFjZSBpcyBmdW5jdGlvbmFsIGFmdGVyIDMgYW5kIDEwMCBUQ1AgY29u
bmVjdGlvbnMuIFRoYW5rcw0KICAgDQoNCg==
