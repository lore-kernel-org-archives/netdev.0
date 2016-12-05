From: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Subject: Re: [net PATCH 2/2] ipv4: Drop suffix update from resize code
Date: Mon, 5 Dec 2016 17:36:52 +0000
Message-ID: <1480959410.11947.14.camel@intel.com>
References: <20161201121605.15499.13176.stgit@ahduyck-blue-test.jf.intel.com>
         <20161201122757.15499.51778.stgit@ahduyck-blue-test.jf.intel.com>
         <46f96f3a-0e8a-5eff-0f2d-7aeb6aec8c23@brocade.com>
         <20161205.122846.557360857895468724.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "davem@davemloft.net" <davem@davemloft.net>,
        "rshearma@brocade.com" <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:56079 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751433AbcLERgx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Dec 2016 12:36:53 -0500
In-Reply-To: <20161205.122846.557360857895468724.davem@davemloft.net>
Content-Language: en-US
Content-ID: <DFA2837DA906DB4EA32D83F24D0610CD@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gTW9uLCAyMDE2LTEyLTA1IGF0IDEyOjI4IC0wNTAwLCBEYXZpZCBNaWxsZXIgd3JvdGU6DQo+
IEZyb206IFJvYmVydCBTaGVhcm1hbiA8cnNoZWFybWFAYnJvY2FkZS5jb20+DQo+IERhdGU6IE1v
biwgNSBEZWMgMjAxNiAxNTowNToxOCArMDAwMA0KPiANCj4gPiANCj4gPiBPbiAwMS8xMi8xNiAx
MjoyNywgQWxleGFuZGVyIER1eWNrIHdyb3RlOg0KPiA+ID4gDQo+ID4gPiBJdCBoYXMgYmVlbiBy
ZXBvcnRlZCB0aGF0IHVwZGF0ZV9zdWZmaXggY2FuIGJlIGV4cGVuc2l2ZSB3aGVuIGl0IGlzDQo+
ID4gPiBjYWxsZWQNCj4gPiA+IG9uIGEgbGFyZ2Ugbm9kZSBpbiB3aGljaCBtb3N0IG9mIHRoZSBz
dWZmaXggbGVuZ3RocyBhcmUgdGhlIHNhbWUuICBUaGUNCj4gPiA+IHRpbWUNCj4gPiA+IHJlcXVp
cmVkIHRvIGFkZCAyMDBLIGVudHJpZXMgaGFkIGluY3JlYXNlZCBmcm9tIGFyb3VuZCAzIHNlY29u
ZHMgdG8NCj4gPiA+IGFsbW9zdA0KPiA+ID4gNDkgc2Vjb25kcy4NCj4gPiA+IA0KPiA+ID4gSW4g
b3JkZXIgdG8gYWRkcmVzcyB0aGlzIHdlIG5lZWQgdG8gbW92ZSB0aGUgY29kZSBmb3IgdXBkYXRp
bmcgdGhlDQo+ID4gPiBzdWZmaXgNCj4gPiA+IG91dCBvZiByZXNpemUgYW5kIGluc3RlYWQganVz
dCBoYXZlIGl0IGhhbmRsZWQgaW4gdGhlIGNhc2VzIHdoZXJlIHdlDQo+ID4gPiBhcmUNCj4gPiA+
IHB1c2hpbmcgYSBub2RlIHRoYXQgaW5jcmVhc2VzIHRoZSBzdWZmaXggbGVuZ3RoLCBvciB3aWxs
IGRlY3JlYXNlIHRoZQ0KPiA+ID4gc3VmZml4IGxlbmd0aC4NCj4gPiA+IA0KPiA+ID4gRml4ZXM6
IDU0MDVhZmQxYTMwNiAoImZpYl90cmllOiBBZGQgdHJhY2tpbmcgdmFsdWUgZm9yIHN1ZmZpeCBs
ZW5ndGgiKQ0KPiA+ID4gUmVwb3J0ZWQtYnk6IFJvYmVydCBTaGVhcm1hbiA8cnNoZWFybWFAYnJv
Y2FkZS5jb20+DQo+ID4gPiBTaWduZWQtb2ZmLWJ5OiBBbGV4YW5kZXIgRHV5Y2sgPGFsZXhhbmRl
ci5oLmR1eWNrQGludGVsLmNvbT4NCj4gPiANCj4gPiAkIHRpbWUgc3VkbyBpcCByb3V0ZSByZXN0
b3JlIDwgfi9hbGxyb3V0ZXMNCj4gPiBSVE5FVExJTksgYW5zd2VyczogRmlsZSBleGlzdHMNCj4g
PiBSVE5FVExJTksgYW5zd2VyczogRmlsZSBleGlzdHMNCj4gPiBSVE5FVExJTksgYW5zd2Vyczog
RmlsZSBleGlzdHMNCj4gPiBSVE5FVExJTksgYW5zd2VyczogRmlsZSBleGlzdHMNCj4gDQo+IFdo
YXQgYXJlIHRoZXNlIGVycm9ycyBhbGwgYWJvdXQ/DQoNCkkgdGhpbmsgaXQgaXMgdGhlIGZhY3Qg
dGhhdCBoZSBpcyB0cnlpbmcgdG8gcmVzdG9yZSAiYWxsIHJvdXRlcyIgYW5kDQpzb21lIG9mIHRo
ZSByb3V0ZXMgYWxyZWFkeSBleGlzdCBzdWNoIGFzIHRob3NlIGFzc29jaWF0ZWQgd2l0aCBoaXMN
CmRlZmF1bHQgbmV0d29yayBpbnRlcmZhY2UuDQoNCi0gQWxleA==
