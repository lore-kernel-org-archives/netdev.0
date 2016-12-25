From: Nogah Frankel <nogahf@mellanox.com>
Subject: RE: [PATCH iproute2 v3 2/4] ifstat: Add extended statistics to ifstat
Date: Sun, 25 Dec 2016 10:25:18 +0000
Message-ID: <VI1PR05MB1902B99C24BF14CAC3DA6B5BAC970@VI1PR05MB1902.eurprd05.prod.outlook.com>
References: <1482423795-6531-1-git-send-email-nogahf@mellanox.com>
        <1482423795-6531-3-git-send-email-nogahf@mellanox.com>
 <20161222105919.08b8738b@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
        "roszenrami@gmail.com" <roszenrami@gmail.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>, Elad Raz <eladr@mellanox.com>,
        Yotam Gigi <yotamg@mellanox.com>,
        Ido Schimmel <idosch@mellanox.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0063.outbound.protection.outlook.com ([104.47.2.63]:44434
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752547AbcLYK6F (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 25 Dec 2016 05:58:05 -0500
In-Reply-To: <20161222105919.08b8738b@xeon-e3>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBTdGVwaGVuIEhlbW1pbmdlciBb
bWFpbHRvOnN0ZXBoZW5AbmV0d29ya3BsdW1iZXIub3JnXQ0KPiBTZW50OiBUaHVyc2RheSwgRGVj
ZW1iZXIgMjIsIDIwMTYgODo1OSBQTQ0KPiBUbzogTm9nYWggRnJhbmtlbCA8bm9nYWhmQG1lbGxh
bm94LmNvbT4NCj4gQ2M6IG5ldGRldkB2Z2VyLmtlcm5lbC5vcmc7IHJvb3BhQGN1bXVsdXNuZXR3
b3Jrcy5jb207IHJvc3plbnJhbWlAZ21haWwuY29tOyBPcg0KPiBHZXJsaXR6IDxvZ2VybGl0ekBt
ZWxsYW5veC5jb20+OyBKaXJpIFBpcmtvIDxqaXJpQG1lbGxhbm94LmNvbT47IEVsYWQgUmF6DQo+
IDxlbGFkckBtZWxsYW5veC5jb20+OyBZb3RhbSBHaWdpIDx5b3RhbWdAbWVsbGFub3guY29tPjsg
SWRvIFNjaGltbWVsDQo+IDxpZG9zY2hAbWVsbGFub3guY29tPg0KPiBTdWJqZWN0OiBSZTogW1BB
VENIIGlwcm91dGUyIHYzIDIvNF0gaWZzdGF0OiBBZGQgZXh0ZW5kZWQgc3RhdGlzdGljcyB0byBp
ZnN0YXQNCj4gDQo+IE9uIFRodSwgMjIgRGVjIDIwMTYgMTg6MjM6MTMgKzAyMDANCj4gTm9nYWgg
RnJhbmtlbCA8bm9nYWhmQG1lbGxhbm94LmNvbT4gd3JvdGU6DQo+IE9uIFRodSwgMjIgRGVjIDIw
MTYgMTg6MjM6MTMgKzAyMDANCj4gTm9nYWggRnJhbmtlbCA8bm9nYWhmQG1lbGxhbm94LmNvbT4g
d3JvdGU6DQo+IA0KPiA+ICB9DQo+ID4gQEAgLTY5MSwxOCArODA0LDIyIEBAIHN0YXRpYyBjb25z
dCBzdHJ1Y3Qgb3B0aW9uIGxvbmdvcHRzW10gPSB7DQo+ID4gIAl7ICJpbnRlcnZhbCIsIDEsIDAs
ICd0JyB9LA0KPiA+ICAJeyAidmVyc2lvbiIsIDAsIDAsICdWJyB9LA0KPiA+ICAJeyAiemVyb3Mi
LCAwLCAwLCAneicgfSwNCj4gPiArCXsgImV4dGVuZGVkIiwgMSwgMCwgJ3gnfSwNCj4gPiAgCXsg
MCB9DQo+ID4gIH07DQo+ID4NCj4gPiArDQo+ID4gIGludCBtYWluKGludCBhcmdjLCBjaGFyICph
cmd2W10pDQo+IA0KPiBZb3UgbGV0IGV4dHJhIHdoaXRlc3BhY2UgY2hhbmdlcyBjcmVlcCBpbi4N
Cj4gDQo+IA0KPiA+ICsJCWNhc2UgJ3gnOg0KPiA+ICsJCQlpc19leHRlbmRlZCA9IHRydWU7DQo+
ID4gKwkJCW1lbXNldChzdGF0c190eXBlLCAwLCA2NCk7DQo+ID4gKwkJCXN0cm5jcHkoc3RhdHNf
dHlwZSwgb3B0YXJnLCA2Myk7DQo+ID4gKwkJCWJyZWFrOw0KPiANCj4gVGhpcyBzZWVtcyBsaWtl
IGRvaW5nIHRoaXMgZWl0aGVyIHRoZSBwYXJhbm9pZCBvciBoYXJkIHdheS4NCj4gV2h5IG5vdDoN
Cj4gCWNvbnN0IGNoYXIgKnN0YXRzX3R5cGUgPSBOVUxMOw0KPiAuLi4NCj4gDQo+IAljYXNlICd4
JzoNCj4gCQlzdGF0c190eXBlID0gb3B0YXJnOw0KPiAJCWJyZWFrOw0KPiAuLi4NCj4gCQlpZiAo
c3RhdHNfdHlwZSkNCj4gCQkJc25wcmludGYoaGlzdF9uYW1lLCBzaXplb2YoaGlzdF9uYW1lKSwN
Cj4gCQkJCSAiJXMvLiVzX2lmc3RhdC51JWQiLCBQX3RtcGRpciwgc3RhdHNfdHlwZSwNCj4gCQkJ
CSBnZXR1aWQoKSk7DQo+IAkJZWxzZQ0KPiAJCQlzbnByaW50ZihoaXN0X25hbWUsIHNpemVvZiho
aXN0X25hbWUpLA0KPiAJCQkJICIlcy8uaWZzdGF0LnUlZCIsIFBfdG1wZGlyLCBnZXR1aWQoKSk7
DQo+IA0KPiANCj4gU2luY2U6DQo+IAkxKSBvcHRhcmcgcG9pbnRzIHRvIGFyZWEgaW4gYXJndiB0
aGF0IGlzIHBlcnNpc3RlbnQgKGF2b2lkIGNvcHkpDQo+IAkyKSBkb24ndCBuZWVkIGlzX2V4dGVu
ZGVkIGZsYWcgdmFsdWUgdGhlbg0KPiANCj4gUGxlYXNlIGNsZWFudXAgYW5kIHJlc3VibWl0Lg0K
PiANCj4gDQoNCkkgd2lsbC4NClRoYW5rIHlvdS4NCg0KDQo=
