From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: Re: [PATCH net-next 3/4] igb: enable internal PPS for the i210.
Date: Mon, 17 Nov 2014 23:24:27 +0000
Message-ID: <1416266666.21363.48.camel@jekeller-desk1.amr.corp.intel.com>
References: <cover.1416265321.git.richardcochran@gmail.com>
	 <e5b4ef7c56119e2d86e42f5680b1b82c9ec1a38e.1416265321.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Vick, Matthew" <matthew.vick@intel.com>
To: "richardcochran@gmail.com" <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:48353 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751297AbaKQXYb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2014 18:24:31 -0500
In-Reply-To: <e5b4ef7c56119e2d86e42f5680b1b82c9ec1a38e.1416265321.git.richardcochran@gmail.com>
Content-Language: en-US
Content-ID: <724274DB40BC2348BBBDA2C602B01E73@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gVHVlLCAyMDE0LTExLTE4IGF0IDAwOjA2ICswMTAwLCBSaWNoYXJkIENvY2hyYW4gd3JvdGU6
DQo+IFRoZSBpMjEwIGRldmljZSBjYW4gcHJvZHVjZSBhbiBpbnRlcnJ1cHQgb24gdGhlIGZ1bGwg
c2Vjb25kLiBUaGlzDQo+IHBhdGNoIGFsbG93cyB1c2luZyB0aGlzIGludGVycnVwdCB0byBnZW5l
cmF0ZSBhbiBpbnRlcm5hbCBQUFMgZXZlbnQNCj4gZm9yIGFkanVzdGluZyB0aGUga2VybmVsIHN5
c3RlbSB0aW1lLg0KPiANCj4gU2lnbmVkLW9mZi1ieTogUmljaGFyZCBDb2NocmFuIDxyaWNoYXJk
Y29jaHJhbkBnbWFpbC5jb20+DQo+IC0tLQ0KPiAgZHJpdmVycy9uZXQvZXRoZXJuZXQvaW50ZWwv
aWdiL2lnYl9tYWluLmMgfCAgICA2ICsrKysrKw0KPiAgZHJpdmVycy9uZXQvZXRoZXJuZXQvaW50
ZWwvaWdiL2lnYl9wdHAuYyAgfCAgIDMyICsrKysrKysrKysrKysrKysrKysrKysrKysrKy0tDQo+
ICAyIGZpbGVzIGNoYW5nZWQsIDM2IGluc2VydGlvbnMoKyksIDIgZGVsZXRpb25zKC0pDQo+IA0K
PiBkaWZmIC0tZ2l0IGEvZHJpdmVycy9uZXQvZXRoZXJuZXQvaW50ZWwvaWdiL2lnYl9tYWluLmMg
Yi9kcml2ZXJzL25ldC9ldGhlcm5ldC9pbnRlbC9pZ2IvaWdiX21haW4uYw0KPiBpbmRleCA3MTgz
YTU2Li45NDEyNjYxIDEwMDY0NA0KPiAtLS0gYS9kcml2ZXJzL25ldC9ldGhlcm5ldC9pbnRlbC9p
Z2IvaWdiX21haW4uYw0KPiArKysgYi9kcml2ZXJzL25ldC9ldGhlcm5ldC9pbnRlbC9pZ2IvaWdi
X21haW4uYw0KPiBAQCAtNTM4Niw4ICs1Mzg2LDE0IEBAIHZvaWQgaWdiX3VwZGF0ZV9zdGF0cyhz
dHJ1Y3QgaWdiX2FkYXB0ZXIgKmFkYXB0ZXIsDQo+ICBzdGF0aWMgdm9pZCBpZ2JfdHN5bmNfaW50
ZXJydXB0KHN0cnVjdCBpZ2JfYWRhcHRlciAqYWRhcHRlcikNCj4gIHsNCj4gIAlzdHJ1Y3QgZTEw
MDBfaHcgKmh3ID0gJmFkYXB0ZXItPmh3Ow0KPiArCXN0cnVjdCBwdHBfY2xvY2tfZXZlbnQgZXZl
bnQ7DQo+ICAJdTMyIHRzaWNyID0gcmQzMihFMTAwMF9UU0lDUik7DQo+ICANCj4gKwlpZiAodHNp
Y3IgJiBUU0lOVFJfU1lTX1dSQVApIHsNCj4gKwkJZXZlbnQudHlwZSA9IFBUUF9DTE9DS19QUFM7
DQo+ICsJCXB0cF9jbG9ja19ldmVudChhZGFwdGVyLT5wdHBfY2xvY2ssICZldmVudCk7DQo+ICsJ
fQ0KPiArDQoNCk5pY2UhIEkgaGFkbid0IHRob3VnaHQgb2YgdXNpbmcgdGhlIFNZU19XUkFQIGFy
b3VuZCBpbnRlcnJ1cHQgZm9yIHBwcy4NCk11Y2ggc2ltcGxlciB0aGFuIGhhdmluZyB0byBzZXR1
cCBhIFNEUCBwaW4gdHJpZ2dlci4NCg0KUmVnYXJkcywNCkpha2UNCg==
