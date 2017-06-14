From: YUAN Linyu <Linyu.Yuan@alcatel-sbell.com.cn>
Subject: RE: [PATCH net-next 00/11] skb_put_zero() used to optimize code
Date: Wed, 14 Jun 2017 23:45:02 +0000
Message-ID: <8729016553E3654398EA69218DA29EEF15BC8D15@cnshjmbx02>
References: <1497450634-3581-1-git-send-email-cugyly@163.com>
         (sfid-20170614_163132_934852_0520825B)
 <1497451356.9377.1.camel@sipsolutions.net>
         <1497452424.3765.3.camel@163.com>
         <1497457773.9377.2.camel@sipsolutions.net>
 <1497457908.9377.4.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "David S . Miller" <davem@davemloft.net>
To: Johannes Berg <johannes@sipsolutions.net>,
        "cugyly@163.com" <cugyly@163.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cnshjsmin03.alcatel-sbell.com.cn ([116.246.26.71]:59141 "EHLO
        cnshjsmin03.alcatel-sbell.com.cn" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750728AbdFNXpF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 19:45:05 -0400
In-Reply-To: <1497457908.9377.4.camel@sipsolutions.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogbmV0ZGV2LW93bmVyQHZn
ZXIua2VybmVsLm9yZyBbbWFpbHRvOm5ldGRldi1vd25lckB2Z2VyLmtlcm5lbC5vcmddDQo+IE9u
IEJlaGFsZiBPZiBKb2hhbm5lcyBCZXJnDQo+IFNlbnQ6IFRodXJzZGF5LCBKdW5lIDE1LCAyMDE3
IDEyOjMyIEFNDQo+IFRvOiBjdWd5bHlAMTYzLmNvbTsgbmV0ZGV2QHZnZXIua2VybmVsLm9yZw0K
PiBDYzogRGF2aWQgUyAuIE1pbGxlcjsgWVVBTiBMaW55dQ0KPiBTdWJqZWN0OiBSZTogW1BBVENI
IG5ldC1uZXh0IDAwLzExXSBza2JfcHV0X3plcm8oKSB1c2VkIHRvIG9wdGltaXplIGNvZGUNCj4g
DQo+IE9uIFdlZCwgMjAxNy0wNi0xNCBhdCAxODoyOSArMDIwMCwgSm9oYW5uZXMgQmVyZyB3cm90
ZToNCj4gPiBPbiBXZWQsIDIwMTctMDYtMTQgYXQgMjM6MDAgKzA4MDAsIHl1YW4gbGlueXUgd3Jv
dGU6DQo+ID4NCj4gPiA+IHNvcnJ5LCBJIGRvIHRoZW0gYnkgaGFuZC4NCj4gPg0KPiA+IG9oLCBv
ay4NCj4gPg0KPiA+IFRoaXMgc2VlbXMgdG8gd29yazoNCj4gPg0KPiA+IEBADQo+ID4gaWRlbnRp
ZmllciBwOw0KPiA+IGV4cHJlc3Npb24gbGVuOw0KPiA+IGV4cHJlc3Npb24gc2tiOw0KPiA+IHR5
cGUgdDsNCj4gPiBAQA0KPiA+IC1wID0gKHQpc2tiX3B1dChza2IsIGxlbik7DQo+ID4gLW1lbXNl
dChwLCAwLCBsZW4pOw0KPiA+ICtwID0gKHQpc2tiX3B1dF96ZXJvKHNrYiwgbGVuKTsNCj4gDQo+
IE5vcGUsIHN0aWxsIGRpZG4ndCBmaW5kIGV2ZXJ5dGhpbmcgLSBub3QgdGhlIGJhdG1hbiBhbmQg
YXRtIGNhc2VzIGZvcg0KPiBleGFtcGxlLiBCdXQgc3RpbGwgYSBmZXcgbW9yZSwgSSB0aGluayB0
aGF0IHlvdSBkaWRuJ3QgZmluZCwgZS5nLiBpbg0KPiBtYWM4MDIxMS4NClllcywgSSB0aG91Z2h0
IHlvdSBhbHJlYWR5IGRvbmUgaW4gbWFjODAyMTENCj4gDQo+IEFueXdheSAtIEkgdGhpbmsgbm9u
ZSBvZiB0aGlzIGlzIHJlYWxseSBjcml0aWNhbC4NCj4gDQo+IGpvaGFubmVzDQo=
