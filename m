From: "Liang, Kan" <kan.liang@intel.com>
Subject: RE: [RFC 1/2] net/ethtool: Add new coalescing parameter for queue
Date: Tue, 8 Dec 2015 19:43:29 +0000
Message-ID: <37D7C6CF3E00A74B8858931C1DB2F077019AA989@SHSMSX103.ccr.corp.intel.com>
References: <1449549750-12448-1-git-send-email-kan.liang@intel.com>
	 <CAP-MU4OHMz8DaMwvF7=0ZgMCFdW0_85KH5O5ke55-X6Ox1Vw2Q@mail.gmail.com>
 <1449601252.2824.101.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"bwh@kernel.org" <bwh@kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"andi@firstfloor.org" <andi@firstfloor.org>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"alexander.duyck@gmail.com" <alexander.duyck@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
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
	"tj@kernel.org" <tj@kernel.org
To: Ben Hutchings <ben@decadent.org.uk>,
	"Nelson, Shannon" <shannon.nelson@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:39791 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752205AbbLHTnd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Dec 2015 14:43:33 -0500
In-Reply-To: <1449601252.2824.101.camel@decadent.org.uk>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQoNCj4gDQo+IE9uIFR1ZSwgMjAxNS0xMi0wOCBhdCAxMDowMiAtMDgwMCwgU2hhbm5vbiBOZWxz
b24gd3JvdGU6DQo+ID4gT24gTW9uLCBEZWMgNywgMjAxNSBhdCA4OjQyIFBNLMKgwqA8a2FuLmxp
YW5nQGludGVsLmNvbT4gd3JvdGU6DQo+ID4gPiBGcm9tOiBLYW4gTGlhbmcgPGthbi5saWFuZ0Bp
bnRlbC5jb20+DQo+ID4gPg0KPiA+ID4gSW50cmRvdWNlICJxdWV1ZSIgb3B0aW9uIGZvciBjb2Fs
ZXNjZSBnZXR0aW5nIGFuZCBzZXR0aW5nLg0KPiBbLi4uXQ0KPiA+ID4gLS0tIGEvbmV0L2NvcmUv
ZXRodG9vbC5jDQo+ID4gPiArKysgYi9uZXQvY29yZS9ldGh0b29sLmMNCj4gPiA+IEBAIC0xMTIz
LDEwICsxMTIzLDE2IEBAIHN0YXRpYyBub2lubGluZV9mb3Jfc3RhY2sgaW50DQo+ID4gPiBldGh0
b29sX2dldF9jb2FsZXNjZShzdHJ1Y3QgbmV0X2RldmljZSAqZGV2LA0KPiA+ID4gwqDCoMKgwqDC
oMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKg
wqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgdm9pZCBfX3VzZXINCj4gPiA+ICp1
c2VyYWRkcikNCj4gPiA+IMKgew0KPiA+ID4gwqDCoMKgwqDCoMKgwqDCoHN0cnVjdCBldGh0b29s
X2NvYWxlc2NlIGNvYWxlc2NlID0geyAuY21kID0NCj4gPiA+IEVUSFRPT0xfR0NPQUxFU0NFIH07
DQo+ID4gPiArwqDCoMKgwqDCoMKgwqBzdHJ1Y3QgZXRodG9vbF9jb2FsZXNjZSB0bXAgPSB7IC5x
dWV1ZSA9IC0xIH07DQo+ID4gPg0KPiA+ID4gwqDCoMKgwqDCoMKgwqDCoGlmICghZGV2LT5ldGh0
b29sX29wcy0+Z2V0X2NvYWxlc2NlKQ0KPiA+ID4gwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDC
oMKgwqByZXR1cm4gLUVPUE5PVFNVUFA7DQo+ID4gPg0KPiA+ID4gK8KgwqDCoMKgwqDCoMKgaWYg
KGNvcHlfZnJvbV91c2VyKCZ0bXAsIHVzZXJhZGRyLCBzaXplb2YoY29hbGVzY2UpKSkNCj4gPiA+
ICvCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqByZXR1cm4gLUVGQVVMVDsNCj4gPiA+ICsN
Cj4gPiA+ICvCoMKgwqDCoMKgwqDCoGNvYWxlc2NlLnF1ZXVlID0gdG1wLnF1ZXVlOw0KPiA+ID4g
Kw0KPiA+DQo+ID4gSXMgdGhpcyBnb2luZyB0byBkbyB3aGF0IHlvdSBleHBlY3Qgd2hlbiB5b3Ug
aGF2ZSBhbiBvbGRlciBldGh0b29sDQo+ID4gcHJvZ3JhbT/CoMKgSXQgc2VlbXMgdG8gbWUgdGhh
dCB0aGUgb2xkZXIgZXRodG9vbCBwcm9ncmFtIHdpbGwgaGF2ZSB0aGUNCj4gPiBvcmlnaW5hbCBj
b2FsZXNjZSBzdHJ1Y3Qgd2l0aG91dCB0aGUgbmV3IHF1ZXVlIGZpZWxkLCBzbyB3aGVuIHlvdSBk
bw0KPiBbLi4uXQ0KPiANCj4gSW5kZWVkLCBpdCdzIG5vdCBzYWZlIHRvIGV4dGVuZCBVQVBJIHN0
cnVjdHVyZXMgbGlrZSB0aGlzLg0KDQpBbnkgc3VnZ2VzdGlvbnMgZm9yIHRoYXQ/DQpJZiB3ZSBj
YW5ub3QgZXh0ZW5kIHRoZSBleGlzdGluZyBVQVBJIHN0cnVjdHVyZXMuIEkgZ3Vlc3Mgd2UgaGF2
ZSB0byBhZGQNCmEgbmV3IElvY3RsIGxpa2UgRVRIVE9PTF9HQ09BTEVTQ0VfVjIgZm9yIHRoZSBu
ZXcgc3RydWN0dXJlPw0KDQpUaGFua3MsDQpLYW4NCg0KDQo=
