From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [net-next 13/15] ixgbe: implement SFF diagnostic monitoring via
 ethtool
Date: Wed, 20 Feb 2013 00:26:37 +0000
Message-ID: <87618083B2453E4A8714035B62D67992337C63A8@FMSMSX102.amr.corp.intel.com>
References: <1361003616-3422-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1361003616-3422-14-git-send-email-jeffrey.t.kirsher@intel.com>
 <1361312048.2967.44.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Ben Hutchings <bhutchings@solarflare.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	=?utf-8?B?QXVyw6lsaWVuIEd1aWxsYXVtZQ==?= <footplus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:43776 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934049Ab3BTA0q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Feb 2013 19:26:46 -0500
In-Reply-To: <1361312048.2967.44.camel@bwh-desktop.uk.solarflarecom.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pi0tLS0tT3JpZ2luYWwgTWVzc2FnZS0tLS0tDQo+RnJvbTogQmVuIEh1dGNoaW5ncyBbbWFpbHRv
OmJodXRjaGluZ3NAc29sYXJmbGFyZS5jb21dDQo+U2VudDogVHVlc2RheSwgRmVicnVhcnkgMTks
IDIwMTMgMjoxNCBQTQ0KPlRvOiBLaXJzaGVyLCBKZWZmcmV5IFQ7IEF1csOpbGllbiBHdWlsbGF1
bWUNCj5DYzogZGF2ZW1AZGF2ZW1sb2Z0Lm5ldDsgbmV0ZGV2QHZnZXIua2VybmVsLm9yZzsgZ29z
cG9AcmVkaGF0LmNvbTsNCj5zYXNzbWFubkByZWRoYXQuY29tOyBUYW50aWxvdiwgRW1pbCBTDQo+
U3ViamVjdDogUmU6IFtuZXQtbmV4dCAxMy8xNV0gaXhnYmU6IGltcGxlbWVudCBTRkYgZGlhZ25v
c3RpYyBtb25pdG9yaW5nDQo+dmlhIGV0aHRvb2wNCj4NCj5PbiBTYXQsIDIwMTMtMDItMTYgYXQg
MDA6MzMgLTA4MDAsIEplZmYgS2lyc2hlciB3cm90ZToNCj4+IEZyb206IEF1csOpbGllbiBHdWls
bGF1bWUgPGZvb3RwbHVzQGdtYWlsLmNvbT4NCj4+DQo+PiBUaGlzIHBhdGNoIGFkZHMgc3VwcG9y
dCBmb3IgcmVhZGluZyBkYXRhIGZyb20gU0ZQKyBtb2R1bGVzIG92ZXIgaTJjLg0KPlsuLi5dDQo+
PiAtLS0gYS9kcml2ZXJzL25ldC9ldGhlcm5ldC9pbnRlbC9peGdiZS9peGdiZV9ldGh0b29sLmMN
Cj4+ICsrKyBiL2RyaXZlcnMvbmV0L2V0aGVybmV0L2ludGVsL2l4Z2JlL2l4Z2JlX2V0aHRvb2wu
Yw0KPlsuLi5dDQo+PiArc3RhdGljIGludCBpeGdiZV9nZXRfbW9kdWxlX2VlcHJvbShzdHJ1Y3Qg
bmV0X2RldmljZSAqZGV2LA0KPj4gKwkJCQkJIHN0cnVjdCBldGh0b29sX2VlcHJvbSAqZWUsDQo+
PiArCQkJCQkgdTggKmRhdGEpDQo+PiArew0KPj4gKwlzdHJ1Y3QgaXhnYmVfYWRhcHRlciAqYWRh
cHRlciA9IG5ldGRldl9wcml2KGRldik7DQo+PiArCXN0cnVjdCBpeGdiZV9odyAqaHcgPSAmYWRh
cHRlci0+aHc7DQo+PiArCXUzMiBzdGF0dXMgPSBJWEdCRV9FUlJfUEhZX0FERFJfSU5WQUxJRDsN
Cj4+ICsJdTggZGF0YWJ5dGUgPSAweEZGOw0KPj4gKwlpbnQgaSA9IDA7DQo+PiArCWludCByZXRf
dmFsID0gMDsNCj4+ICsNCj4+ICsJLyogaXhnYmVfZ2V0X21vZHVsZV9pbmZvIGlzIGNhbGxlZCBi
ZWZvcmUgdGhpcyBmdW5jdGlvbiBpbiBhbGwNCj4+ICsJICogY2FzZXMsIHNvIHdlIGRvIG5vdCBu
ZWVkIGFueSBjaGVja3Mgd2UgYWxyZWFkeSBkbyBhYm92ZSwNCj4+ICsJICogYW5kIGNhbiB0cnVz
dCBlZS0+bGVuIHRvIGJlIGEga25vd24gdmFsdWUuDQo+PiArCSAqLw0KPlsuLi5dDQo+DQo+V2hh
dGV2ZXIgbWFrZXMgeW91IHRoaW5rIHRoYXQ/DQo+DQo+QWxsIHlvdSBhcmUgZ3VhcmFudGVlZCBp
cyB0aGF0Og0KPiAgICBlZS0+b2Zmc2V0IDw9IGVlLT5vZmZzZXQgKyBlZS0+bGVuIDw9IGVlcHJv
bV9sZW4NCj5TYW1lIGFzIGZvciB0aGUgcmVndWxhciBFRVBST00gcmVhZCBmdW5jdGlvbi4NCj4N
Cj5UaGlzIGltcGxlbWVudGF0aW9uIGRvZXNuJ3QgcmVzdWx0IGluIGEgaGVhcCBvdmVycnVuIGF0
IHByZXNlbnQgYmVjYXVzZQ0KPnRoZSBjYWxsZXIgYWxsb2NhdGVzIGEgd2hvbGUgcGFnZSBhcyBh
IGJ1ZmZlci4gIEJ1dCB5b3Ugc2hvdWxkIG5vdA0KPmFzc3VtZSB0aGF0IGl0J3Mgc2FmZSB0byB3
cml0ZSBtb3JlIHRoYW4gZWUtPmxlbiBieXRlcywgbm9yIHRoYXQNCj5lZS0+b2Zmc2V0ID09IDAu
DQo+DQo+QmVuLg0KDQpUaGFua3MgQmVuLCB3ZSdsbCBhZGRyZXNzIHRoaXMgaW4gYSBmb2xsb3cg
dXAgcGF0Y2guDQoNCkVtaWwNCg0KDQo=
