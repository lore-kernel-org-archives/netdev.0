From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] tcp: fix compiler array bounds warning on
 selective_acks[]
Date: Fri, 11 Apr 2014 08:59:57 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6F5DFA@AcuExch.aculab.com>
References: <20140410213029.24916.93892.stgit@bhelgaas-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	James Morris <jmorris@namei.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Patrick McHardy <kaber@trash.net>
To: 'Bjorn Helgaas' <bhelgaas@google.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140410213029.24916.93892.stgit@bhelgaas-glaptop.roam.corp.google.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Qmpvcm4gSGVsZ2FhcyANCj4gV2l0aCAtV2Vycm9yPWFycmF5LWJvdW5kcywgZ2NjIHY0LjgueCB3
YXJucyB0aGF0IGluIHRjcF9zYWNrX3JlbW92ZSgpLCBhDQo+IHNlbGVjdGl2ZV9hY2tzW10gImFy
cmF5IHN1YnNjcmlwdCBpcyBhYm92ZSBhcnJheSBib3VuZHMiLg0KPiANCj4gSSBkb24ndCB1bmRl
cnN0YW5kIGhvdyBnY2MgZmlndXJlcyB0aGlzIG91dCwgb3Igd2h5IHdlIGRvbid0IHNlZSBzaW1p
bGFyDQo+IHByb2JsZW1zIG1hbnkgb3RoZXIgcGxhY2VzLCBidXQgdGhpcyBpcyB0aGUgb25seSBm
aXggSSBjYW4gZmlndXJlIG91dC4NCi4uLg0KPiBkaWZmIC0tZ2l0IGEvbmV0L2lwdjQvdGNwX2lu
cHV0LmMgYi9uZXQvaXB2NC90Y3BfaW5wdXQuYw0KPiBpbmRleCA2NWNmOTBlMDYzZDUuLjY1MTMz
YjEwODIzNiAxMDA2NDQNCj4gLS0tIGEvbmV0L2lwdjQvdGNwX2lucHV0LmMNCj4gKysrIGIvbmV0
L2lwdjQvdGNwX2lucHV0LmMNCj4gQEAgLTQwNDcsNyArNDA0Nyw4IEBAIHN0YXRpYyB2b2lkIHRj
cF9zYWNrX3JlbW92ZShzdHJ1Y3QgdGNwX3NvY2sgKnRwKQ0KPiANCj4gIAkJCS8qIFphcCB0aGlz
IFNBQ0ssIGJ5IG1vdmluZyBmb3J3YXJkIGFueSBvdGhlciBTQUNLUy4gKi8NCj4gIAkJCWZvciAo
aSA9IHRoaXNfc2FjaysxOyBpIDwgbnVtX3NhY2tzOyBpKyspDQo+IC0JCQkJdHAtPnNlbGVjdGl2
ZV9hY2tzW2ktMV0gPSB0cC0+c2VsZWN0aXZlX2Fja3NbaV07DQo+ICsJCQkJaWYgKGkgPCBBUlJB
WV9TSVpFKHRwLT5zZWxlY3RpdmVfYWNrcykpDQo+ICsJCQkJCXRwLT5zZWxlY3RpdmVfYWNrc1tp
LTFdID0gdHAtPnNlbGVjdGl2ZV9hY2tzW2ldOw0KPiAgCQkJbnVtX3NhY2tzLS07DQo+ICAJCQlj
b250aW51ZTsNCj4gIAkJfQ0KDQpZb3UgcmVhbGx5IHNob3VsZG4ndCBhZGQgdGhhdCB0ZXN0IGV2
ZXJ5IHRpbWUgYXJvdW5kIHRoZSBsb29wLg0KDQpUcnkgY2hhbmdpbmcgdGhlIGxvb3Agc28gdGhl
IGFzc2lnbm1lbnQgaXM6DQogICB0cC0+c2VsZWN0aXZlX2Fja3NbaV0gPSB0cC0+c2VsZWN0aXZl
X2Fja3NbaSArIDFdOw0KDQpvciB0aGUgbG9vcCB0ZXN0IHRvOg0KCWkgPD0gbnVtX3NhY2tzIC0g
MTsNCg0KT3IgYmVhdCB1cCB0aGUgZ2NjIGRldmVsb3BlcnMgOi0pDQoNCglEYXZpZA0KDQo=
