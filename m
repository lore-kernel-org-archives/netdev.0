From: "Liang, Kan" <kan.liang@intel.com>
Subject: RE: [PATCH V3 1/6] net/ethtool: introduce a new ioctl for per queue
 setting
Date: Mon, 18 Jan 2016 02:25:10 +0000
Message-ID: <37D7C6CF3E00A74B8858931C1DB2F077058775A4@SHSMSX103.ccr.corp.intel.com>
References: <1452780487-10581-1-git-send-email-kan.liang@intel.com>
 <1452996017.2519.29.camel@decadent.org.uk>
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
	"bwh@kernel.org" <bwh@kernel.org>,
	"decot@googlers.com" <decot@googlers.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:15318 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753371AbcARCZQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Jan 2016 21:25:16 -0500
In-Reply-To: <1452996017.2519.29.camel@decadent.org.uk>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiANCj4gT24gVGh1LCAyMDE2LTAxLTE0IGF0IDA5OjA4IC0wNTAwLCBrYW4ubGlhbmdAaW50ZWwu
Y29tIHdyb3RlOg0KPiBbLi4uXQ0KPiA+IC0tLSBhL2luY2x1ZGUvdWFwaS9saW51eC9ldGh0b29s
LmgNCj4gPiArKysgYi9pbmNsdWRlL3VhcGkvbGludXgvZXRodG9vbC5oDQo+ID4gQEAgLTExNDQs
NiArMTE0NCwyMSBAQCBlbnVtIGV0aHRvb2xfc2ZlYXR1cmVzX3JldHZhbF9iaXRzIHsNCj4gPiDC
oCNkZWZpbmUgRVRIVE9PTF9GX1dJU0jCoMKgwqDCoMKgwqDCoMKgwqDCoCgxIDw8IEVUSFRPT0xf
Rl9XSVNIX19CSVQpDQo+ID4gwqAjZGVmaW5lIEVUSFRPT0xfRl9DT01QQVTCoMKgwqDCoMKgwqDC
oMKgKDEgPDwgRVRIVE9PTF9GX0NPTVBBVF9fQklUKQ0KPiA+DQo+ID4gKyNkZWZpbmUgTUFYX05V
TV9RVUVVRQkJNDA5Ng0KPiA+ICsNCj4gPiArLyoqDQo+ID4gKyAqIHN0cnVjdCBldGh0b29sX3Bl
cl9xdWV1ZV9vcCAtIGFwcGx5IHN1YiBjb21tYW5kIHRvIHRoZSBxdWV1ZXMgaW4NCj4gbWFzay4N
Cj4gPiArICogQGNtZDogRVRIVE9PTF9QRVJRVUVVRQ0KPiA+ICsgKiBAc3ViX2NvbW1hbmQ6IHRo
ZSBzdWIgY29tbWFuZCB3aGljaCBhcHBseSB0byBlYWNoIHF1ZXVlcw0KPiA+ICsgKiBAcXVldWVf
bWFzazogQml0bWFwIG9mIHRoZSBxdWV1ZXMgd2hpY2ggc3ViIGNvbW1hbmQgYXBwbHkgdG8NCj4g
PiArICogQGRhdGE6IEEgY29tcGxldGUgY29tbWFuZCBzdHJ1Y3R1cmUgZm9sbG93aW5nIGZvciBl
YWNoIG9mIHRoZQ0KPiA+ICtxdWV1ZXMgYWRkcmVzc2VkICAqLyBzdHJ1Y3QgZXRodG9vbF9wZXJf
cXVldWVfb3Agew0KPiA+ICsJX191MzIJY21kOw0KPiA+ICsJX191MzIJc3ViX2NvbW1hbmQ7DQo+
ID4gKwl1bnNpZ25lZCBsb25nDQo+IHF1ZXVlX21hc2tbQklUU19UT19MT05HUyhNQVhfTlVNX1FV
RVVFKV07DQo+IFsuLi5dDQo+IA0KPiBJIHRob3VnaHQgd2UgYWxyZWFkeSBhZ3JlZWQgdGhhdCB0
aGlzIHdvbid0IHdvcmsgZm9yIDMyLWJpdCB1c2VybGFuZCBvbiBhDQo+IGJpZy1lbmRpYW4gNjQt
Yml0IGtlcm5lbD8NCg0KSSBmb3VuZCBEYXZpZCBEZWNvdGlnbnkncyBwYXRjaC4gaHR0cHM6Ly9s
a21sLm9yZy9sa21sLzIwMTUvMTIvMTQvNzI4DQpCdXQgaXQgbG9va3MgbGlrZSBpdCBpcyBub3Qg
bWVyZ2VkIHlldC4gDQpBbnkgaWRlYSB3aGVuIGl0IHdpbGwgYmUgbWVyZ2VkIHRvIG5ldC1uZXh0
IG9yIG5ldD8NClNvIEkgY2FuIGJ1aWxkIG15IHBhdGNoIG9uIHRvcCBvZiBoaXMgcGF0Y2guDQoN
ClRoYW5rcywNCkthbg0KDQo+IA0KPiBCZW4uDQo+IA0KPiAtLQ0KPiBCZW4gSHV0Y2hpbmdzDQo+
IFRoZW9yeSBhbmQgcHJhY3RpY2UgYXJlIGNsb3NlciBpbiB0aGVvcnkgdGhhbiBpbiBwcmFjdGlj
ZS4NCj4gICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAtIEpvaG4gTGV2aW5lLCBtb2Rl
cmF0b3Igb2YgY29tcC5jb21waWxlcnMNCg==
