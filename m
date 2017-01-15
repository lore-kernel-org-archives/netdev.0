From: Nogah Frankel <nogahf@mellanox.com>
Subject: RE: [PATCH iproute2 v4 3/4] ifstat: Add 64 bits based stats to
 extended statistics
Date: Sun, 15 Jan 2017 13:54:57 +0000
Message-ID: <DB5PR05MB18959E57F2BD8427DDEBDC89AC7A0@DB5PR05MB1895.eurprd05.prod.outlook.com>
References: <1484228991-32999-1-git-send-email-nogahf@mellanox.com>
        <1484228991-32999-4-git-send-email-nogahf@mellanox.com>
 <20170112174335.1bd391c2@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "roszenrami@gmail.com" <roszenrami@gmail.com>,
        "roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Ido Schimmel <idosch@mellanox.com>,
        Elad Raz <eladr@mellanox.com>,
        Yotam Gigi <yotamg@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr00049.outbound.protection.outlook.com ([40.107.0.49]:35840
        "EHLO EUR02-AM5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751153AbdAONzM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 15 Jan 2017 08:55:12 -0500
In-Reply-To: <20170112174335.1bd391c2@xeon-e3>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogU3RlcGhlbiBIZW1taW5n
ZXIgW21haWx0bzpzdGVwaGVuQG5ldHdvcmtwbHVtYmVyLm9yZ10NCj4gU2VudDogRnJpZGF5LCBK
YW51YXJ5IDEzLCAyMDE3IDM6NDQgQU0NCj4gVG86IE5vZ2FoIEZyYW5rZWwgPG5vZ2FoZkBtZWxs
YW5veC5jb20+DQo+IENjOiBuZXRkZXZAdmdlci5rZXJuZWwub3JnOyByb3N6ZW5yYW1pQGdtYWls
LmNvbTsgcm9vcGFAY3VtdWx1c25ldHdvcmtzLmNvbTsgSmlyaQ0KPiBQaXJrbyA8amlyaUBtZWxs
YW5veC5jb20+OyBJZG8gU2NoaW1tZWwgPGlkb3NjaEBtZWxsYW5veC5jb20+OyBFbGFkIFJheg0K
PiA8ZWxhZHJAbWVsbGFub3guY29tPjsgWW90YW0gR2lnaSA8eW90YW1nQG1lbGxhbm94LmNvbT47
IE9yIEdlcmxpdHoNCj4gPG9nZXJsaXR6QG1lbGxhbm94LmNvbT4NCj4gU3ViamVjdDogUmU6IFtQ
QVRDSCBpcHJvdXRlMiB2NCAzLzRdIGlmc3RhdDogQWRkIDY0IGJpdHMgYmFzZWQgc3RhdHMgdG8g
ZXh0ZW5kZWQgc3RhdGlzdGljcw0KPiANCj4gT24gVGh1LCAxMiBKYW4gMjAxNyAxNTo0OTo1MCAr
MDIwMA0KPiBOb2dhaCBGcmFua2VsIDxub2dhaGZAbWVsbGFub3guY29tPiB3cm90ZToNCj4gDQo+
ID4gVGhlIGRlZmF1bHQgc3RhdHMgZm9yIGlmc3RhdCBhcmUgMzIgYml0cyBiYXNlZC4NCj4gPiBU
aGUga2VybmVsIHN1cHBvcnRzIDY0IGJpdHMgYmFzZWQgc3RhdHMuIChUaGV5IGFyZSByZXR1cm5l
ZCBpbiBzdHJ1Y3QNCj4gPiBydG5sX2xpbmtfc3RhdHM2NCB3aGljaCBpcyBhbiBleGFjdCBjb3B5
IG9mIHN0cnVjdCBydG5sX2xpbmtfc3RhdHMsIGluDQo+ID4gd2hpY2ggdGhlICJub3JtYWwiIHN0
YXRzIGFyZSByZXR1cm5lZCwgYnV0IHdpdGggZmllbGRzIG9mIHU2NCBpbnN0ZWFkIG9mDQo+ID4g
dTMyKS4gVGhpcyBwYXRjaCBhZGRzIHRoZW0gYXMgYW4gZXh0ZW5kZWQgc3RhdHMuDQo+ID4NCj4g
PiBJdCBpcyByZWFkIHdpdGggZmlsdGVyIHR5cGUgSUZMQV9TVEFUU19MSU5LXzY0IGFuZCBubyBz
dWIgdHlwZS4NCj4gPg0KPiA+IEl0IGlzIHVuZGVyIHRoZSBuYW1lIDY0Yml0cw0KPiA+IChvciBh
bnkgc2hvcnRlbiBvZiBpdCBhcyAiNjQiKQ0KPiA+DQo+ID4gRm9yIGV4YW1wbGU6DQo+ID4gaWZz
dGF0IC14IDY0Yml0DQo+ID4NCj4gPiBTaWduZWQtb2ZmLWJ5OiBOb2dhaCBGcmFua2VsIDxub2dh
aGZAbWVsbGFub3guY29tPg0KPiA+IFJldmlld2VkLWJ5OiBKaXJpIFBpcmtvIDxqaXJpQG1lbGxh
bm94LmNvbT4NCj4gDQo+IE90aGVyIGNvbW1hbmRzIChsaWtlIGlwIGxpbmspIGFsd2F5cyB1c2Ug
dGhlIDY0IGJpdCBzdGF0aXN0aWNzIGlmIGF2YWlsYWJsZQ0KPiBmcm9tIHRoZSBkZXZpY2UuIEkg
c2VlIG5vIHJlYXNvbiB0aGF0IGlmc3RhdCBuZWVkcyB0byBiZSBkaWZmZXJlbnQuDQo+IA0KDQpE
byB5b3UgbWVhbiB0byBjaGFuZ2UgdGhlIGRlZmF1bHQgaWZzdGF0IHJlc3VsdHMgdG8gYmUgNjQg
Yml0cyBiYXNlZD8NCkkgdHJpZWQgaXQgaW4gdGhlIGZpcnN0IHZlcnNpb24sIGJ1dCBSb29wYSBj
b21tZW50ZWQgdGhhdCBpdCB3YXMgbm90IGEgZ29vZCBpZGVhLg0KU2hlIHNhaWQgdGhleSB0cmll
ZCBpdCBpbiB0aGUgcGFzdCBhbmQgaXQgY2F1c2VkIGJhY2t3YXJkIGNvbXBhdGliaWxpdGllcyBw
cm9ibGVtcy4NCihPciBtYXliZSBJIGRpZG4ndCB1bmRlcnN0YW5kIGNvcnJlY3RseSkNCg0K
