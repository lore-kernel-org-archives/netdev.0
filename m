From: "Liang, Kan" <kan.liang@intel.com>
Subject: RE: [RFC 1/5] net/ethtool: introduce a new ioctl for per queue
 setting
Date: Mon, 21 Dec 2015 20:03:55 +0000
Message-ID: <37D7C6CF3E00A74B8858931C1DB2F077019C1404@SHSMSX103.ccr.corp.intel.com>
References: <1450335081-3012-1-git-send-email-kan.liang@intel.com>
 <1450495632.30687.3.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"andi@firstfloor.org" <andi@firstfloor.org>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"alexander.duyck@gmail.com" <alexander.duyck@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Nelson, Shannon" <shannon.nelson@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"edumazet@google.com" <edumazet@google.com>,
	"jiri@mellanox.com" <jiri@mellanox.com>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>,
	"sasha.levin@oracle.com" <sasha.levin@oracle.com>,
	"dsahern@gmail.com" <dsahern@gmail.com>,
	"tj@kernel.org" <tj@kernel.org>,
	"cascardo@redhat.com" <cascardo@redhat.com>,
	"corbet@lwn.net" <corbet@lwn
To: Ben Hutchings <ben@decadent.org.uk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"bwh@kernel.org" <bwh@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:43915 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750914AbbLUUEA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Dec 2015 15:04:00 -0500
In-Reply-To: <1450495632.30687.3.camel@decadent.org.uk>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQoNCj4gPiArI2RlZmluZSBNQVhfUVVFVUUJCTQwOTYNCj4gPiArI2RlZmluZSBNQVhfUVVFVUVf
TUFTSwkJKE1BWF9RVUVVRSAvIDY0KQ0KPiA+ICsNCj4gPiArLyoqDQo+ID4gKyAqIHN0cnVjdCBl
dGh0b29sX3Blcl9xdWV1ZV9vcCAtIGFwcGx5IHN1YiBjb21tYW5kIHRvIHRoZSBxdWV1ZXMgaW4N
Cj4gbWFzay4NCj4gPiArICogQGNtZDogRVRIVE9PTF9QRVJRVUVVRQ0KPiA+ICsgKiBAcXVldWVf
bWFzazogTWFzayB0aGUgcXVldWVzIHdoaWNoIHN1YiBjb21tYW5kIGFwcGx5IHRvDQo+ID4gKyAq
IEBzdWJfY29tbWFuZDogdGhlIHN1YiBjb21tYW5kDQo+ID4gKyAqIEBkYXRhOiBwYXJhbWV0ZXJz
IG9mIHRoZSBjb21tYW5kDQo+ID4gKyAqLw0KPiA+ICtzdHJ1Y3QgZXRodG9vbF9wZXJfcXVldWVf
b3Agew0KPiA+ICsJX191MzIJY21kOw0KPiA+ICsJX191NjQJcXVldWVfbWFza1tNQVhfUVVFVUVf
TUFTS107DQo+ID4gKwlfX3UzMglzdWJfY29tbWFuZDsNCj4gDQo+IFRoaXMgbGVhdmVzIGEgaG9s
ZSBpbiB0aGUgc3RydWN0dXJlIG9uIGkzODYsIHdoaWNoIHdvdWxkIHRoZW4gcmVxdWlyZQ0KPiBj
b252ZXJzaW9uIGluIHRoZSBjb21wYXQgaW9jdGwgaW1wbGVtZW50YXRpb24uIMKgSSBzdWdnZXN0
IHlvdSBtb3ZlIHRoZQ0KPiBzdWJfY29tbWFuZCBuZXh0IHRvIGNtZC4NCg0KT0suIEkgd2lsbCBt
b2RpZnkgaXQgaW4gVjIuDQoNCj4gDQo+ID4gKwljaGFyCWRhdGFbXTsNCj4gPiArfTsNCj4gPg0K
PiA+IMKgLyogQ01EcyBjdXJyZW50bHkgc3VwcG9ydGVkICovDQo+ID4gwqAjZGVmaW5lIEVUSFRP
T0xfR1NFVAkJMHgwMDAwMDAwMSAvKiBHZXQgc2V0dGluZ3MuICovDQo+ID4gQEAgLTEyMjYsNiAr
MTI0Miw4IEBAIGVudW0gZXRodG9vbF9zZmVhdHVyZXNfcmV0dmFsX2JpdHMgew0KPiA+IMKgI2Rl
ZmluZSBFVEhUT09MX0dUVU5BQkxFCTB4MDAwMDAwNDggLyogR2V0IHR1bmFibGUNCj4gY29uZmln
dXJhdGlvbiAqLw0KPiA+IMKgI2RlZmluZSBFVEhUT09MX1NUVU5BQkxFCTB4MDAwMDAwNDkgLyog
U2V0IHR1bmFibGUNCj4gY29uZmlndXJhdGlvbiAqLw0KPiA+DQo+ID4gKyNkZWZpbmUgRVRIVE9P
TF9QRVJRVUVVRQkweDAwMDAwMDRhIC8qIFNldCBwZXIgcXVldWUNCj4gb3B0aW9ucyAqLw0KPiAN
Cj4gQnV0IGl0IHdpbGwgYWN0dWFsbHkgYmUgdXNlZCBmb3IgYm90aCBzZXQgYW5kIGdldCwgcmln
aHQ/DQoNClJpZ2h0Lg0KDQo+IA0KPiA+ICsNCj4gPiDCoC8qIGNvbXBhdGliaWxpdHkgd2l0aCBv
bGRlciBjb2RlICovDQo+ID4gwqAjZGVmaW5lIFNQQVJDX0VUSF9HU0VUCQlFVEhUT09MX0dTRVQN
Cj4gPiDCoCNkZWZpbmUgU1BBUkNfRVRIX1NTRVQJCUVUSFRPT0xfU1NFVA0KPiA+IGRpZmYgLS1n
aXQgYS9uZXQvY29yZS9ldGh0b29sLmMgYi9uZXQvY29yZS9ldGh0b29sLmMgaW5kZXgNCj4gPiAy
OWVkZjc0Li4xMjVmYjMyIDEwMDY0NA0KPiA+IC0tLSBhL25ldC9jb3JlL2V0aHRvb2wuYw0KPiA+
ICsrKyBiL25ldC9jb3JlL2V0aHRvb2wuYw0KPiA+IEBAIC0xNzQ4LDYgKzE3NDgsMjAgQEAgb3V0
Og0KPiA+IMKgCXJldHVybiByZXQ7DQo+ID4gwqB9DQo+ID4NCj4gPiArc3RhdGljIGludCBldGh0
b29sX3NldF9wZXJfcXVldWUoc3RydWN0IG5ldF9kZXZpY2UgKmRldiwgdm9pZCBfX3VzZXINCj4g
PiArKnVzZXJhZGRyKSB7DQo+ID4gKwlzdHJ1Y3QgZXRodG9vbF9wZXJfcXVldWVfb3AgcGVyX3F1
ZXVlX29wdDsNCj4gPiArDQo+ID4gKwlpZiAoY29weV9mcm9tX3VzZXIoJnBlcl9xdWV1ZV9vcHQs
IHVzZXJhZGRyLA0KPiBzaXplb2YocGVyX3F1ZXVlX29wdCkpKQ0KPiA+ICsJCXJldHVybiAtRUZB
VUxUOw0KPiA+ICsNCj4gPiArCXN3aXRjaCAocGVyX3F1ZXVlX29wdC5zdWJfY29tbWFuZCkgew0K
PiA+ICsNCj4gPiArCWRlZmF1bHQ6DQo+ID4gKwkJcmV0dXJuIC1FT1BOT1RTVVBQOw0KPiA+ICsJ
fTsNCj4gPiArfQ0KPiA+ICsNCj4gPiDCoC8qIFRoZSBtYWluIGVudHJ5IHBvaW50IGluIHRoaXMg
ZmlsZS7CoMKgQ2FsbGVkIGZyb20NCj4gPiBuZXQvY29yZS9kZXZfaW9jdGwuYyAqLw0KPiA+DQo+
ID4gwqBpbnQgZGV2X2V0aHRvb2woc3RydWN0IG5ldCAqbmV0LCBzdHJ1Y3QgaWZyZXEgKmlmcikg
QEAgLTE5OTEsNg0KPiA+ICsyMDA1LDkgQEAgaW50IGRldl9ldGh0b29sKHN0cnVjdCBuZXQgKm5l
dCwgc3RydWN0IGlmcmVxICppZnIpDQo+ID4gwqAJY2FzZSBFVEhUT09MX1NUVU5BQkxFOg0KPiA+
IMKgCQlyYyA9IGV0aHRvb2xfc2V0X3R1bmFibGUoZGV2LCB1c2VyYWRkcik7DQo+ID4gwqAJCWJy
ZWFrOw0KPiA+ICsJY2FzZSBFVEhUT09MX1BFUlFVRVVFOg0KPiA+ICsJCXJjID0gZXRodG9vbF9z
ZXRfcGVyX3F1ZXVlKGRldiwgdXNlcmFkZHIpOw0KPiA+ICsJCWJyZWFrOw0KPiA+IMKgCWRlZmF1
bHQ6DQo+ID4gwqAJCXJjID0gLUVPUE5PVFNVUFA7DQo+ID4gwqAJfQ0KPiANCj4gSSB0aGluayB0
aGUgZmlyc3Qgc3dpdGNoIHN0YXRlbWVudCB0byBkZXRlcm1pbmUgd2hldGhlciB0aGUgY29tbWFu
ZA0KPiByZXF1aXJlcyBDQVBfTkVUX0FETUlOIHNob3VsZCBhbHNvIGhhbmRsZSBFVEhUT09MX1BF
UlFVRVVFLA0KPiBjaGVja2luZyB0aGUgc3ViLWNvbW1hbmQgbnVtYmVyLg0KPg0KDQpPSy4gSSB3
aWxsIGFkZCBpdCBpbiBWMi4gT25seSAnZ2V0JyBjYW4gYmUgZG9uZSBieSBhbnlvbmUuDQoNClRo
YW5rcywNCkthbg0KDQogDQo=
