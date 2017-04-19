From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: RE: [PATCH net-next] i40evf: hide unused variable
Date: Wed, 19 Apr 2017 20:47:58 +0000
Message-ID: <02874ECE860811409154E81DA85FBB5857E088EB@ORSMSX115.amr.corp.intel.com>
References: <20170419173008.3648215-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "Pujari, Bimmy" <bimmy.pujari@intel.com>,
        "Duyck, Alexander H" <alexander.h.duyck@intel.com>,
        "Williams, Mitch A" <mitch.a.williams@intel.com>,
        "Brady, Alan" <alan.brady@intel.com>,
        "Joe Perches" <joe@perches.com>,
        "Singhai, Anjali" <anjali.singhai@intel.com>,
        "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
        "Banala, Preethi" <preethi.banala@intel.com>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:47655 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S939581AbdDSUsF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 19 Apr 2017 16:48:05 -0400
In-Reply-To: <20170419173008.3648215-1-arnd@arndb.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBBcm5kIEJlcmdtYW5uIFttYWls
dG86YXJuZEBhcm5kYi5kZV0NCj4gU2VudDogV2VkbmVzZGF5LCBBcHJpbCAxOSwgMjAxNyAxMDoz
MCBBTQ0KPiBUbzogS2lyc2hlciwgSmVmZnJleSBUIDxqZWZmcmV5LnQua2lyc2hlckBpbnRlbC5j
b20+DQo+IENjOiBBcm5kIEJlcmdtYW5uIDxhcm5kQGFybmRiLmRlPjsgUHVqYXJpLCBCaW1teQ0K
PiA8YmltbXkucHVqYXJpQGludGVsLmNvbT47IER1eWNrLCBBbGV4YW5kZXIgSA0KPiA8YWxleGFu
ZGVyLmguZHV5Y2tAaW50ZWwuY29tPjsgV2lsbGlhbXMsIE1pdGNoIEENCj4gPG1pdGNoLmEud2ls
bGlhbXNAaW50ZWwuY29tPjsgS2VsbGVyLCBKYWNvYiBFIDxqYWNvYi5lLmtlbGxlckBpbnRlbC5j
b20+OyBCcmFkeSwNCj4gQWxhbiA8YWxhbi5icmFkeUBpbnRlbC5jb20+OyBKb2UgUGVyY2hlcyA8
am9lQHBlcmNoZXMuY29tPjsgU2luZ2hhaSwgQW5qYWxpDQo+IDxhbmphbGkuc2luZ2hhaUBpbnRl
bC5jb20+OyBCcmFuZGVidXJnLCBKZXNzZSA8amVzc2UuYnJhbmRlYnVyZ0BpbnRlbC5jb20+Ow0K
PiBCYW5hbGEsIFByZWV0aGkgPHByZWV0aGkuYmFuYWxhQGludGVsLmNvbT47IGludGVsLXdpcmVk
LWxhbkBsaXN0cy5vc3Vvc2wub3JnOw0KPiBuZXRkZXZAdmdlci5rZXJuZWwub3JnOyBsaW51eC1r
ZXJuZWxAdmdlci5rZXJuZWwub3JnDQo+IFN1YmplY3Q6IFtQQVRDSCBuZXQtbmV4dF0gaTQwZXZm
OiBoaWRlIHVudXNlZCB2YXJpYWJsZQ0KPiANCj4gT24gYXJjaGl0ZWN0dXJlcyB3aXRoIGxhcmdl
ciBwYWdlcywgd2UgZ2V0IGEgd2FybmluZyBhYm91dCBhbiB1bnVzZWQgdmFyaWFibGU6DQo+IA0K
PiBkcml2ZXJzL25ldC9ldGhlcm5ldC9pbnRlbC9pNDBldmYvaTQwZXZmX21haW4uYzogSW4gZnVu
Y3Rpb24NCj4gJ2k0MGV2Zl9jb25maWd1cmVfcngnOg0KPiBkcml2ZXJzL25ldC9ldGhlcm5ldC9p
bnRlbC9pNDBldmYvaTQwZXZmX21haW4uYzo2OTA6MjE6IGVycm9yOiB1bnVzZWQgdmFyaWFibGUN
Cj4gJ25ldGRldicgWy1XZXJyb3I9dW51c2VkLXZhcmlhYmxlXQ0KPiANCj4gVGhpcyBtb3ZlcyB0
aGUgZGVjbGFyYXRpb24gaW50byB0aGUgI2lmZGVmIHRvIGF2b2lkIHRoZSB3YXJuaW5nLg0KPiAN
Cg0KTWFrZXMgc2Vuc2UuDQoNCkFja2VkLWJ5OiBKYWNvYiBLZWxsZXIgPGphY29iLmUua2VsbGVy
QGludGVsLmNvbT4NCg0KPiBGaXhlczogZGFiODZhZmRiYmQxICgiaTQwZS9pNDBldmY6IENoYW5n
ZSB0aGUgd2F5IHdlIGxpbWl0IHRoZSBtYXhpbXVtIGZyYW1lDQo+IHNpemUgZm9yIFJ4IikNCj4g
U2lnbmVkLW9mZi1ieTogQXJuZCBCZXJnbWFubiA8YXJuZEBhcm5kYi5kZT4NCj4gLS0tDQo+ICBk
cml2ZXJzL25ldC9ldGhlcm5ldC9pbnRlbC9pNDBldmYvaTQwZXZmX21haW4uYyB8IDMgKystDQo+
ICAxIGZpbGUgY2hhbmdlZCwgMiBpbnNlcnRpb25zKCspLCAxIGRlbGV0aW9uKC0pDQo+IA0KPiBk
aWZmIC0tZ2l0IGEvZHJpdmVycy9uZXQvZXRoZXJuZXQvaW50ZWwvaTQwZXZmL2k0MGV2Zl9tYWlu
LmMNCj4gYi9kcml2ZXJzL25ldC9ldGhlcm5ldC9pbnRlbC9pNDBldmYvaTQwZXZmX21haW4uYw0K
PiBpbmRleCAxMmE5MzBlODc5YWYuLjFiYjEzYzg2NGVkZCAxMDA2NDQNCj4gLS0tIGEvZHJpdmVy
cy9uZXQvZXRoZXJuZXQvaW50ZWwvaTQwZXZmL2k0MGV2Zl9tYWluLmMNCj4gKysrIGIvZHJpdmVy
cy9uZXQvZXRoZXJuZXQvaW50ZWwvaTQwZXZmL2k0MGV2Zl9tYWluLmMNCj4gQEAgLTY4NywxMyAr
Njg3LDE0IEBAIHN0YXRpYyB2b2lkIGk0MGV2Zl9jb25maWd1cmVfdHgoc3RydWN0IGk0MGV2Zl9h
ZGFwdGVyDQo+ICphZGFwdGVyKQ0KPiAgc3RhdGljIHZvaWQgaTQwZXZmX2NvbmZpZ3VyZV9yeChz
dHJ1Y3QgaTQwZXZmX2FkYXB0ZXIgKmFkYXB0ZXIpDQo+ICB7DQo+ICAJdW5zaWduZWQgaW50IHJ4
X2J1Zl9sZW4gPSBJNDBFX1JYQlVGRkVSXzIwNDg7DQo+IC0Jc3RydWN0IG5ldF9kZXZpY2UgKm5l
dGRldiA9IGFkYXB0ZXItPm5ldGRldjsNCj4gIAlzdHJ1Y3QgaTQwZV9odyAqaHcgPSAmYWRhcHRl
ci0+aHc7DQo+ICAJaW50IGk7DQo+IA0KPiAgCS8qIExlZ2FjeSBSeCB3aWxsIGFsd2F5cyBkZWZh
dWx0IHRvIGEgMjA0OCBidWZmZXIgc2l6ZS4gKi8NCj4gICNpZiAoUEFHRV9TSVpFIDwgODE5MikN
Cj4gIAlpZiAoIShhZGFwdGVyLT5mbGFncyAmIEk0MEVWRl9GTEFHX0xFR0FDWV9SWCkpIHsNCj4g
KwkJc3RydWN0IG5ldF9kZXZpY2UgKm5ldGRldiA9IGFkYXB0ZXItPm5ldGRldjsNCj4gKw0KPiAg
CQkvKiBGb3IganVtYm8gZnJhbWVzIG9uIHN5c3RlbXMgd2l0aCA0SyBwYWdlcyB3ZSBoYXZlIHRv
IHVzZQ0KPiAgCQkgKiBhbiBvcmRlciAxIHBhZ2UsIHNvIHdlIG1pZ2h0IGFzIHdlbGwgaW5jcmVh
c2UgdGhlIHNpemUNCj4gIAkJICogb2Ygb3VyIFJ4IGJ1ZmZlciB0byBtYWtlIGJldHRlciB1c2Ug
b2YgdGhlIGF2YWlsYWJsZSBzcGFjZQ0KPiAtLQ0KPiAyLjkuMA0KDQo=
