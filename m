From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [net-next-2.6 25/27] e1000e: static analysis tools complain of
 a possible null ptr p dereference
Date: Fri, 10 Dec 2010 12:35:45 -0700
Message-ID: <EA929A9653AAE14F841771FB1DE5A136602D54FD2F@rrsmsx501.amr.corp.intel.com>
References: <1291975585-30576-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1291975585-30576-2-git-send-email-jeffrey.t.kirsher@intel.com>
 <1291985090.24978.17.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"davem@davemleft.org" <davem@davemleft.org>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"bphilips@novell.com" <bphilips@novell.com>
To: Joe Perches <joe@perches.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:52452 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755486Ab0LJTgH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Dec 2010 14:36:07 -0500
In-Reply-To: <1291985090.24978.17.camel@Joe-Laptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pi0tLS0tT3JpZ2luYWwgTWVzc2FnZS0tLS0tDQo+RnJvbTogbmV0ZGV2LW93bmVyQHZnZXIua2Vy
bmVsLm9yZyBbbWFpbHRvOm5ldGRldi1vd25lckB2Z2VyLmtlcm5lbC5vcmddIE9uDQo+QmVoYWxm
IE9mIEpvZSBQZXJjaGVzDQo+U2VudDogRnJpZGF5LCBEZWNlbWJlciAxMCwgMjAxMCA0OjQ1IEFN
DQo+VG86IEtpcnNoZXIsIEplZmZyZXkgVA0KPkNjOiBkYXZlbUBkYXZlbWxvZnQubmV0OyBkYXZl
bUBkYXZlbWxlZnQub3JnOyBBbGxhbiwgQnJ1Y2UgVzsNCj5uZXRkZXZAdmdlci5rZXJuZWwub3Jn
OyBnb3Nwb0ByZWRoYXQuY29tOyBicGhpbGlwc0Bub3ZlbGwuY29tDQo+U3ViamVjdDogUmU6IFtu
ZXQtbmV4dC0yLjYgMjUvMjddIGUxMDAwZTogc3RhdGljIGFuYWx5c2lzIHRvb2xzIGNvbXBsYWlu
IG9mDQo+YSBwb3NzaWJsZSBudWxsIHB0ciBwIGRlcmVmZXJlbmNlDQo+DQo+T24gRnJpLCAyMDEw
LTEyLTEwIGF0IDAyOjA2IC0wODAwLCBKZWZmIEtpcnNoZXIgd3JvdGU6DQo+PiBkaWZmIC0tZ2l0
IGEvZHJpdmVycy9uZXQvZTEwMDBlL2V0aHRvb2wuYyBiL2RyaXZlcnMvbmV0L2UxMDAwZS9ldGh0
b29sLmMNCj5bXQ0KPj4gKwkJZGVmYXVsdDoNCj4+ICsJCQlkYXRhW2ldID0gMDsNCj4+ICsJCQlj
b250aW51ZTsNCj4+ICsJCQlicmVhazsNCj4NCj5Vc2luZw0KPg0KPgljb250aW51ZTsNCj4JYnJl
YWs7DQo+DQo+aXMgb2RkIGFuZCB1bmhlbHBmdWwuDQo+SnVzdCBjb250aW51ZTsgaXMgc3VmZmlj
aWVudCBhbmQgY2xlYXIuDQoNCkl0J3Mgb2RkIGFuZCB3aXRob3V0IGNvbnNlcXVlbmNlIGJ1dCBu
b3QgbmVjZXNzYXJpbHkgInVuaGVscGZ1bCIgYXMgaXQgY2FuIHByb3RlY3QgZnJvbSBidWdzIGlu
IGNhc2Ugc29tZW9uZSB3YXMgdG8gYWRkIGFub3RoZXIgY2FzZSBzdGF0ZW1lbnQuIFdoaWxlIHVu
bGlrZWx5LCBidWdzIGluIHN3aXRjaCBzdGF0ZW1lbnRzIGR1ZSB0byBtaXNzaW5nIGJyZWFrcyBh
cmUgbm90IHVuaGVhcmQgb2YuDQoNCkxvb2tpbmcgYXQgdGhlIGtlcm5lbCBzb3VyY2UgdGhlcmUg
aXMgbm8gY29uc2lzdGVuY3kgYXMgZmFyIGFzIGJyZWFrIGluIHRoZSBkZWZhdWx0OiBjYXNlIGlz
IGNvbmNlcm5lZC4NCg0KRGF2ZSwgdW5sZXNzIHRoaXMgaXMgaW5mcmluZ2luZyBvbiBzb21lIGNv
ZGluZyBzdHlsZSBydWxlLCBJIHdvdWxkIHJlcXVlc3QgdGhhdCB0aGUgcGF0Y2ggYmUgYXBwbGll
ZCBhcyBpcy4NCg0KVGhhbmtzLA0KRW1pbA0KDQo=
