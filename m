From: "Liang, Kan" <kan.liang@intel.com>
Subject: RE: [RFC 3/5] net/ethtool: support set coalesce per queue
Date: Mon, 21 Dec 2015 20:33:42 +0000
Message-ID: <37D7C6CF3E00A74B8858931C1DB2F077019C1442@SHSMSX103.ccr.corp.intel.com>
References: <1450335081-3012-1-git-send-email-kan.liang@intel.com>
	 <1450335081-3012-3-git-send-email-kan.liang@intel.com>
 <1450496335.30687.15.camel@decadent.org.uk>
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
Received: from mga03.intel.com ([134.134.136.65]:18792 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751661AbbLUUdr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Dec 2015 15:33:47 -0500
In-Reply-To: <1450496335.30687.15.camel@decadent.org.uk>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQoNCj4gT24gVGh1LCAyMDE1LTEyLTE3IGF0IDA2OjUxICswMDAwLCBrYW4ubGlhbmdAaW50ZWwu
Y29tIHdyb3RlOg0KPiBbLi4uXQ0KPiA+IC0tLSBhL25ldC9jb3JlL2V0aHRvb2wuYw0KPiA+ICsr
KyBiL25ldC9jb3JlL2V0aHRvb2wuYw0KPiA+IEBAIC0xNzc4LDYgKzE3NzgsMzcgQEAgc3RhdGlj
IGludA0KPiBldGh0b29sX2dldF9wZXJfcXVldWVfY29hbGVzY2Uoc3RydWN0IG5ldF9kZXZpY2Ug
KmRldiwNCj4gPiDCoAlyZXR1cm4gMDsNCj4gPiDCoH0NCj4gPg0KPiA+ICtzdGF0aWMgaW50IGV0
aHRvb2xfc2V0X3Blcl9xdWV1ZV9jb2FsZXNjZShzdHJ1Y3QgbmV0X2RldmljZSAqZGV2LA0KPiA+
ICsJCQkJCcKgwqB2b2lkIF9fdXNlciAqdXNlcmFkZHIsDQo+ID4gKwkJCQkJwqDCoHN0cnVjdCBl
dGh0b29sX3Blcl9xdWV1ZV9vcA0KPiAqcGVyX3F1ZXVlX29wdCkgew0KPiA+ICsJdTY0IHF1ZXVl
X21hc2s7DQo+ID4gKwlpbnQgYml0LCBpLCByZXQ7DQo+ID4gKw0KPiA+ICsJaWYgKCFkZXYtPmV0
aHRvb2xfb3BzLT5zZXRfcGVyX3F1ZXVlX2NvYWxlc2NlKQ0KPiA+ICsJCXJldHVybiAtRU9QTk9U
U1VQUDsNCj4gPiArDQo+ID4gKwl1c2VyYWRkciArPSBzaXplb2YoKnBlcl9xdWV1ZV9vcHQpOw0K
PiA+ICsJZm9yIChpID0gMDsgaSA8IE1BWF9RVUVVRV9NQVNLOyBpKyspIHsNCj4gPiArCQlxdWV1
ZV9tYXNrID0gcGVyX3F1ZXVlX29wdC0+cXVldWVfbWFza1tpXTsNCj4gPiArCQlpZiAocXVldWVf
bWFzayA+IDApIHsNCj4gPiArCQkJZm9yX2VhY2hfc2V0X2JpdChiaXQsICh1bnNpZ25lZCBsb25n
DQo+ICopJnF1ZXVlX21hc2ssIDY0KSB7DQo+ID4gKwkJCQlzdHJ1Y3QgZXRodG9vbF9jb2FsZXNj
ZSBjb2FsZXNjZTsNCj4gPiArDQo+ID4gKwkJCQlpZiAoY29weV9mcm9tX3VzZXIoJmNvYWxlc2Nl
LCB1c2VyYWRkciwNCj4gc2l6ZW9mKGNvYWxlc2NlKSkpDQo+ID4gKwkJCQkJcmV0dXJuIC1FRkFV
TFQ7DQo+ID4gKw0KPiA+ICsJCQkJcmV0ID0gZGV2LT5ldGh0b29sX29wcy0NCj4gPnNldF9wZXJf
cXVldWVfY29hbGVzY2UoZGV2LCBiaXQgKyBpICogNjQsICZjb2FsZXNjZSk7DQo+ID4gKwkJCQlp
ZiAocmV0ICE9IDApDQo+ID4gKwkJCQkJcmV0dXJuIHJldDsNCj4gWy4uLl0NCj4gDQo+IFNvIHRo
ZXJlJ3Mgbm8gYXR0ZW1wdCB0byByb2xsIGJhY2sgb24gZmFpbHVyZT8NCj4gDQpObywgZXRodG9v
bCBjb3JlIGRvZXNu4oCZdCBzYXZlIHRoZSBvbGQgdmFsdWUgZm9yIHRoaXMgdmVyc2lvbi4gU28g
aXQncyBoYXJkIHRvDQpSb2xsYmFjay4NCklmIHdlIHdhbnQgdGhpcyBmZWF0dXJlLCB0aGUga2Vy
bmVsIHdpbGwgYWxsb2MgYSBjaHVuayBvZiBtZW1vcnkgdG8gc3RvcmUNCmNvYWxlc2NlIHZhbHVl
IGZvciBtYXNrZWQgcXVldWVzLiBJcyBpdCBPSz8NCg0KPiBUaGVuLCB3aGF0IGlzIHRoZSBiZW5l
Zml0IG9mIGRvaW5nIHRoaXMgaXRlcmF0aW9uIGluIHRoZSBrZXJuZWwgcmF0aGVyIHRoYW4NCj4g
dXNlcmxhbmQ/DQo+IA0KSXQgc2hvdWxkIHNhdmUgbWFueSBpb2N0bHMuDQoNClRoYW5rcywNCkth
bg0KDQo=
