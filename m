From: Nogah Frankel <nogahf@mellanox.com>
Subject: RE: [PATCH iproute2 v3 4/4] ifstat: Add "sw only" extended statistics
 to ifstat
Date: Sun, 25 Dec 2016 11:23:33 +0000
Message-ID: <VI1PR05MB19025EDB56AB6ED1F99C807EAC970@VI1PR05MB1902.eurprd05.prod.outlook.com>
References: <1482423795-6531-1-git-send-email-nogahf@mellanox.com>
 <1482423795-6531-5-git-send-email-nogahf@mellanox.com>
 <585C413B.9050905@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "stephen@networkplumber.org" <stephen@networkplumber.org>,
        "roszenrami@gmail.com" <roszenrami@gmail.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>, Elad Raz <eladr@mellanox.com>,
        Yotam Gigi <yotamg@mellanox.com>,
        Ido Schimmel <idosch@mellanox.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0065.outbound.protection.outlook.com ([104.47.2.65]:50880
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753137AbcLYLXj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 25 Dec 2016 06:23:39 -0500
In-Reply-To: <585C413B.9050905@cumulusnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogUm9vcGEgUHJhYmh1IFtt
YWlsdG86cm9vcGFAY3VtdWx1c25ldHdvcmtzLmNvbV0NCj4gU2VudDogVGh1cnNkYXksIERlY2Vt
YmVyIDIyLCAyMDE2IDExOjEwIFBNDQo+IFRvOiBOb2dhaCBGcmFua2VsIDxub2dhaGZAbWVsbGFu
b3guY29tPg0KPiBDYzogbmV0ZGV2QHZnZXIua2VybmVsLm9yZzsgc3RlcGhlbkBuZXR3b3JrcGx1
bWJlci5vcmc7IHJvc3plbnJhbWlAZ21haWwuY29tOyBPcg0KPiBHZXJsaXR6IDxvZ2VybGl0ekBt
ZWxsYW5veC5jb20+OyBKaXJpIFBpcmtvIDxqaXJpQG1lbGxhbm94LmNvbT47IEVsYWQgUmF6DQo+
IDxlbGFkckBtZWxsYW5veC5jb20+OyBZb3RhbSBHaWdpIDx5b3RhbWdAbWVsbGFub3guY29tPjsg
SWRvIFNjaGltbWVsDQo+IDxpZG9zY2hAbWVsbGFub3guY29tPg0KPiBTdWJqZWN0OiBSZTogW1BB
VENIIGlwcm91dGUyIHYzIDQvNF0gaWZzdGF0OiBBZGQgInN3IG9ubHkiIGV4dGVuZGVkIHN0YXRp
c3RpY3MgdG8gaWZzdGF0DQo+IA0KPiBPbiAxMi8yMi8xNiwgODoyMyBBTSwgTm9nYWggRnJhbmtl
bCB3cm90ZToNCj4gPiBBZGQgc3VwcG9ydCBmb3IgZXh0ZW5kZWQgc3RhdGlzdGljcyBvZiBTVyBv
bmx5IHR5cGUsIGZvciBjb3VudGluZyBvbmx5IHRoZQ0KPiA+IHBhY2tldHMgdGhhdCB3ZW50IHZp
YSB0aGUgY3B1LiAodXNlZnVsIGZvciBzeXN0ZW1zIHdpdGggZm9yd2FyZA0KPiA+IG9mZmxvYWRp
bmcpLiBJdCByZWFkcyBpdCBmcm9tIGZpbHRlciB0eXBlIElGTEFfU1RBVFNfTElOS19PRkZMT0FE
X1hTVEFUUw0KPiA+IGFuZCBzdWIgdHlwZSBJRkxBX09GRkxPQURfWFNUQVRTX0NQVV9ISVQuDQo+
ID4NCj4gPiBJdCBpcyB1bmRlciB0aGUgbmFtZSAnc29mdHdhcmUnDQo+ID4gKG9yIGFueSBzaG9y
dGVuIG9mIGl0IGFzICdzb2Z0JyBvciBzaW1wbHkgJ3MnKQ0KPiA+DQo+ID4gRm9yIGV4YW1wbGU6
DQo+ID4gaWZzdGF0IC14IHMNCj4gPg0KPiA+DQo+IE5vZ2FoLCBjYW4gd2Uga2VlcCB0aGUgb3B0
aW9uIG5hbWVzIGNsb3NlciB0byB0aGUgYXR0cmlidXRlIG5hbWVzID8NCj4gVGhhdCB3b3VsZCBh
dm9pZCBzb21lIGNvbmZ1c2lvbiBhbmQgaGVscCB3aXRoIHRoZSBmb2xsb3ctdXAgc3RhdHMuDQo+
IA0KPiBpZnN0YXQgLXggb2ZmbG9hZCBjcHUNCj4gb3INCj4gaWZzdGF0IC14IGNwdQ0KPiANCj4g
Zm9yIG90aGVycyBpdCB3b3VsZCBiZToNCj4gDQo+IGlmc3RhdCAteCBsaW5rIFt2bGFufGlnbXBd
DQo+IGlmc3RhdCAteCB2bGFuDQo+IGlmc3RhdCAteCBpZ21wDQo+IGlmc3RhdCAteCBsYWNwDQo+
IA0KPiBhbmQgc28gb24uLi4NCj4gDQo+IHRoYW5rcyENCg0KU3VyZSwgSSB3aWxsIGNoYW5nZSBp
dC4NCg==
