From: "Templin, Fred L" <Fred.L.Templin@boeing.com>
Subject: RE: missing kfree_skb(skb) in ipv6_frag_rcv()?
Date: Mon, 23 Sep 2013 19:32:37 +0000
Message-ID: <2134F8430051B64F815C691A62D9831811037E@XCH-BLV-504.nw.nos.boeing.com>
References: <1379952298.2485.35.camel@bwh-desktop.uk.level5networks.com>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B7354@saturn3.aculab.com>
	 <1379955122.2485.47.camel@bwh-desktop.uk.level5networks.com>
	 <2134F8430051B64F815C691A62D983181101B8@XCH-BLV-504.nw.nos.boeing.com>
 <1379961431.3165.25.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from slb-mbsout-02.boeing.com ([130.76.64.129]:40414 "EHLO
	slb-mbsout-02.boeing.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752962Ab3IWTcj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Sep 2013 15:32:39 -0400
Received: from slb-mbsout-02.boeing.com (localhost.localdomain [127.0.0.1])
	by slb-mbsout-02.boeing.com (8.14.4/8.14.4/DOWNSTREAM_MBSOUT) with ESMTP id r8NJWcDm016104
	for <netdev@vger.kernel.org>; Mon, 23 Sep 2013 12:32:39 -0700
In-Reply-To: <1379961431.3165.25.camel@edumazet-glaptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SGkgRXJpYywNCg0KVGhhbmtzIGZvciB0aGUgY29ycmVjdGlvbiAtIEkgdGhpbmsgSSBsb3N0IHRy
YWNrIG9mIHRoZSBjb2RlIEkNCnNob3VsZCBoYXZlIGJlZW4gbG9va2luZyBhdC4NCg0KRnJlZA0K
DQo+IC0tLS0tT3JpZ2luYWwgTWVzc2FnZS0tLS0tDQo+IEZyb206IEVyaWMgRHVtYXpldCBbbWFp
bHRvOmVyaWMuZHVtYXpldEBnbWFpbC5jb21dDQo+IFNlbnQ6IE1vbmRheSwgU2VwdGVtYmVyIDIz
LCAyMDEzIDExOjM3IEFNDQo+IFRvOiBUZW1wbGluLCBGcmVkIEwNCj4gQ2M6IG5ldGRldkB2Z2Vy
Lmtlcm5lbC5vcmcNCj4gU3ViamVjdDogUmU6IG1pc3Npbmcga2ZyZWVfc2tiKHNrYikgaW4gaXB2
Nl9mcmFnX3JjdigpPw0KPiANCj4gT24gTW9uLCAyMDEzLTA5LTIzIGF0IDE3OjQyICswMDAwLCBU
ZW1wbGluLCBGcmVkIEwgd3JvdGU6DQo+ID4gSGVsbG8sDQo+ID4NCj4gPiBJbiB0aGUgbW9zdCBy
ZWNlbnQga2VybmVsIHJlbGVhc2VzLCBpbiAuL25ldC9pcHY2L3JlYXNzZW1ibHkuYywNCj4gPiBJ
IHNlZSB0aGUgZm9sbG93aW5nIGNvZGUgYXQgdGhlIGVuZCBvZiAiaXB2Nl9mcmFnX3JjdigpIjoN
Cj4gPg0KPiA+ICsJSVA2X0lOQ19TVEFUU19CSChuZXQsIGlwNl9kc3RfaWRldihza2JfZHN0KHNr
YikpLA0KPiBJUFNUQVRTX01JQl9SRUFTTUZBSUxTKTsNCj4gPiArCWtmcmVlX3NrYihza2IpOw0K
PiA+ICsJcmV0dXJuIC0xOw0KPiA+ICsNCj4gPiArZmFpbF9oZHI6DQo+ID4gKwlJUDZfSU5DX1NU
QVRTKG5ldCwgaXA2X2RzdF9pZGV2KHNrYl9kc3Qoc2tiKSksDQo+IElQU1RBVFNfTUlCX0lOSERS
RVJST1JTKTsNCj4gPiArCWljbXB2Nl9wYXJhbV9wcm9iKHNrYiwgSUNNUFY2X0hEUl9GSUVMRCwN
Cj4gc2tiX25ldHdvcmtfaGVhZGVyX2xlbihza2IpKTsNCj4gPiArCXJldHVybiAtMTsNCj4gPiAr
fQ0KPiA+DQo+ID4gUGVyaGFwcyBJIG1pc3NlZCBpdCwgYnV0IEkgZGlkIG5vdCBmaW5kIGFueXdo
ZXJlIHRoYXQNCj4gJ2ljbXB2Nl9wYXJhbV9wcm9iKCknDQo+ID4gZnJlZXMgdGhlIHNrYiwgYW5k
IGhlbmNlIGl0IGFwcGVhcnMgdGhhdCB0aGVyZSBpcyBhIG1pc3NpbmcNCj4ga2ZyZWVfc2tiKCkN
Cj4gPiBpbiB0aGUgYWJvdmUgY29kZS4gSXMgdGhpcyBhIGJ1Zz8NCj4gDQo+IHZvaWQgaWNtcHY2
X3BhcmFtX3Byb2Ioc3RydWN0IHNrX2J1ZmYgKnNrYiwgdTggY29kZSwgaW50IHBvcykNCj4gew0K
PiAgICAgICAgIGljbXA2X3NlbmQoc2tiLCBJQ01QVjZfUEFSQU1QUk9CLCBjb2RlLCBwb3MpOw0K
PiAgICAgICAgIGtmcmVlX3NrYihza2IpOw0KPiB9DQo+IA0KPiBXZWxsLCBJIGRvIHNlZSBrZnJl
ZV9za2Ioc2tiKSBoZXJlLg0KPiANCg0K
