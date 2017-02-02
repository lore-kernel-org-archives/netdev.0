From: Nogah Frankel <nogahf@mellanox.com>
Subject: RE: [PATCH iproute2 v5 2/4] ifstat: Add extended statistics to ifstat
Date: Thu, 2 Feb 2017 08:53:22 +0000
Message-ID: <DB5PR05MB18954C88F4566581D584942CAC4C0@DB5PR05MB1895.eurprd05.prod.outlook.com>
References: <1485434681-33947-1-git-send-email-nogahf@mellanox.com>
        <1485434681-33947-3-git-send-email-nogahf@mellanox.com>
 <20170129203425.070a27d6@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
        "roszenrami@gmail.com" <roszenrami@gmail.com>,
        "jbenc@redhat.com" <jbenc@redhat.com>,
        "sergei.shtylyov@cogentembedded.com"
        <sergei.shtylyov@cogentembedded.com>,
        Jiri Pirko <jiri@mellanox.com>,
        "Elad Raz" <eladr@mellanox.com>,
        Ido Schimmel <idosch@mellanox.com>,
        Yotam Gigi <yotamg@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-he1eur01on0086.outbound.protection.outlook.com ([104.47.0.86]:26782
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750939AbdBBIx1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 2 Feb 2017 03:53:27 -0500
In-Reply-To: <20170129203425.070a27d6@xeon-e3>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogU3RlcGhlbiBIZW1taW5n
ZXIgW21haWx0bzpzdGVwaGVuQG5ldHdvcmtwbHVtYmVyLm9yZ10NCj4gU2VudDogTW9uZGF5LCBK
YW51YXJ5IDMwLCAyMDE3IDY6MzQgQU0NCj4gVG86IE5vZ2FoIEZyYW5rZWwgPG5vZ2FoZkBtZWxs
YW5veC5jb20+DQo+IENjOiBuZXRkZXZAdmdlci5rZXJuZWwub3JnOyByb29wYUBjdW11bHVzbmV0
d29ya3MuY29tOyByb3N6ZW5yYW1pQGdtYWlsLmNvbTsNCj4gamJlbmNAcmVkaGF0LmNvbTsgc2Vy
Z2VpLnNodHlseW92QGNvZ2VudGVtYmVkZGVkLmNvbTsgSmlyaSBQaXJrbw0KPiA8amlyaUBtZWxs
YW5veC5jb20+OyBFbGFkIFJheiA8ZWxhZHJAbWVsbGFub3guY29tPjsgSWRvIFNjaGltbWVsDQo+
IDxpZG9zY2hAbWVsbGFub3guY29tPjsgWW90YW0gR2lnaSA8eW90YW1nQG1lbGxhbm94LmNvbT47
IE9yIEdlcmxpdHoNCj4gPG9nZXJsaXR6QG1lbGxhbm94LmNvbT4NCj4gU3ViamVjdDogUmU6IFtQ
QVRDSCBpcHJvdXRlMiB2NSAyLzRdIGlmc3RhdDogQWRkIGV4dGVuZGVkIHN0YXRpc3RpY3MgdG8g
aWZzdGF0DQo+IA0KPiBPbiBUaHUsIDI2IEphbiAyMDE3IDE0OjQ0OjM5ICswMjAwDQo+IE5vZ2Fo
IEZyYW5rZWwgPG5vZ2FoZkBtZWxsYW5veC5jb20+IHdyb3RlOg0KPiANCj4gPiBFeHRlbmRlZCBz
dGF0cyBhcmUgcGFydCBvZiB0aGUgUlRNX0dFVFNUQVRTIG1ldGhvZC4gVGhpcyBwYXRjaCBhZGRz
IHRoZW0NCj4gPiB0byBpZnN0YXQuDQo+ID4gV2hpbGUgZXh0ZW5kZWQgc3RhdHMgY2FuIGNvbWUg
aW4gbWFueSBmb3Jtcywgd2Ugc3VwcG9ydCBvbmx5IHRoZQ0KPiA+IHJ0bmxfbGlua19zdGF0czY0
IHN0cnVjdCBmb3IgdGhlbSAod2hpY2ggaXMgdGhlIDY0IGJpdHMgdmVyc2lvbiBvZiBzdHJ1Y3QN
Cj4gPiBydG5sX2xpbmtfc3RhdHMpLg0KPiA+IFdlIHN1cHBvcnQgc3RhdHMgaW4gdGhlIG1haW4g
bmVzdGluZyBsZXZlbCwgb3Igb25lIGxvd2VyLg0KPiA+IFRoZSBleHRlbnNpb24gY2FuIGJlIGNh
bGxlZCBieSBpdHMgbmFtZSBvciBhbnkgc2hvcnRlbiBvZiBpdC4gSWYgdGhlcmUgaXMNCj4gPiBt
b3JlIHRoYW4gb25lIG1hdGNoZWQsIHRoZSBmaXJzdCBvbmUgd2lsbCBiZSBwaWNrZWQuDQo+ID4N
Cj4gPiBUbyBnZXQgdGhlIGV4dGVuZGVkIHN0YXRzIHRoZSBmbGFnIC14IDxzdGF0cyB0eXBlPiBp
cyB1c2VkLg0KPiANCj4gSXQgd291bGQgYmUgYmV0dGVyIGlmIHRoaXMgY29tbWFuZCB1c2VkIDY0
IGJpdCBzdGF0aXN0aWNzIHRyYW5zcGFyZW50bHkNCj4gbGlrZSBvdGhlciB0b29scyBpbiBpcHJv
dXRlMi4gVHJhbnNwYXJlbmN5IGlzIGFsd2F5cyBiZXR0ZXIgdXNlciBleHBlcmllbmNlLg0KDQpG
cm9tIHVzZXIgcG9pbnQgb2YgdmlldywgYWxsIHRoZSBzdGF0aXN0aWNzIGluIGlmc3RhdCBhcmUg
NjQgYml0cyBhbmQgYXJlIHNhdmVkIHRoYXQgd2F5Lg0KV2UgY3VycmVudGx5IGdldCB0aGUgc3Rh
dHMgaW4gMzIgYml0cyBzdHJ1Y3RzIGFuZCB0cmFuc2xhdGUgdGhlbSB0byA2NCBiaXRzLiBJdCBr
ZWVwcyB0cmFjaw0Kb2YgIGludCBvdmVyZmxvd3MgKGluIHRoZSAzMiBiaXRzKS4NClRoZSBwcm9i
bGVtIHdpdGggaXQgaXMgIHRoYXQgaWYgYmV0d2VlbiBvbmUgaWZzdGF0IGNhbGwgdG8gYW5vdGhl
ciBwYXNzZXMgdG9vIG11Y2ggdGltZSwNCm9uZSBtaWdodCBsb3NlIG9uZSBvZiB0aGUgb3ZlcmZs
b3dzLiANCkJ1dCB0byBjaGFuZ2UgaXQgaXMgbm90IGEgdHJpdmlhbCBtYXR0ZXIsIGFuZCBJIGJl
bGlldmUgaXQgaXMgbm90IHJlbGF0ZWQgdG8gdGhlIHhzdGF0IGZlYXR1cmUgSQ0Kd2FudCB0byBh
ZGQuDQpJIGRvbid0IHRoaW5rIEkgdW5kZXJzdG9vZCB3aGF0IGlzIHRoZSBjaGFuZ2UgeW91IHdh
bnQuDQo=
