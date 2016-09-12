From: Nogah Frankel <nogahf@mellanox.com>
Subject: RE: [patch net-next v8 2/3] net: core: Add offload stats to
 if_stats_msg
Date: Mon, 12 Sep 2016 11:29:20 +0000
Message-ID: <DB5PR05MB1895644891EFCDD8F9F619F9ACFF0@DB5PR05MB1895.eurprd05.prod.outlook.com>
References: <1473315593-2078-1-git-send-email-jiri@resnulli.us>
 <1473315593-2078-3-git-send-email-jiri@resnulli.us>
 <0332598A-EFF4-4BB0-BDAE-6A673F54A229@cumulusnetworks.com>
 <72691810-B520-4E46-8B45-83C540039173@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Jiri Pirko <jiri@resnulli.us>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        "Ido Schimmel" <idosch@mellanox.com>,
        Elad Raz <eladr@mellanox.com>,
        Yotam Gigi <yotamg@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        "roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
        "linville@tuxdriver.com" <linville@tuxdriver.com>,
        "tgraf@suug.ch" <tgraf@suug.ch>,
        "gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>,
        "sfeldma@gmail.com" <sfeldma@gmail.com>,
        "sd@queasysnail.net" <sd@queasysnail.net>,
        Eran Ben Elisha <eranbe@mellanox.com>,
        "ast@plumgrid.com" <ast@plumgrid.com>,
        "edumazet@google.com" <edumazet@google.com>,
        "hannes@stressinduktion.org" <hannes@stressinduktion.org>,
        "f.fainelli@gmail.com" <f.f
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr00083.outbound.protection.outlook.com ([40.107.0.83]:32020
        "EHLO EUR02-AM5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1758922AbcILNEW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 12 Sep 2016 09:04:22 -0400
In-Reply-To: <72691810-B520-4E46-8B45-83C540039173@cumulusnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBOaWtvbGF5IEFsZWtzYW5kcm92
IFttYWlsdG86bmlrb2xheUBjdW11bHVzbmV0d29ya3MuY29tXQ0KPiBTZW50OiBGcmlkYXksIFNl
cHRlbWJlciAwOSwgMjAxNiA0OjM5IFBNDQo+IFRvOiBOaWtvbGF5IEFsZWtzYW5kcm92IDxuaWtv
bGF5QGN1bXVsdXNuZXR3b3Jrcy5jb20+DQo+IENjOiBKaXJpIFBpcmtvIDxqaXJpQHJlc251bGxp
LnVzPjsgTGludXggS2VybmVsIE5ldHdvcmsgRGV2ZWxvcGVycyA8bmV0ZGV2QHZnZXIua2VybmVs
Lm9yZz47IERhdmlkIFMuIE1pbGxlcg0KPiA8ZGF2ZW1AZGF2ZW1sb2Z0Lm5ldD47IE5vZ2FoIEZy
YW5rZWwgPG5vZ2FoZkBtZWxsYW5veC5jb20+OyBJZG8gU2NoaW1tZWwgPGlkb3NjaEBtZWxsYW5v
eC5jb20+OyBFbGFkIFJheg0KPiA8ZWxhZHJAbWVsbGFub3guY29tPjsgWW90YW0gR2lnaSA8eW90
YW1nQG1lbGxhbm94LmNvbT47IE9yIEdlcmxpdHogPG9nZXJsaXR6QG1lbGxhbm94LmNvbT47IHJv
b3BhQGN1bXVsdXNuZXR3b3Jrcy5jb207DQo+IGxpbnZpbGxlQHR1eGRyaXZlci5jb207IHRncmFm
QHN1dWcuY2g7IGdvc3BvQGN1bXVsdXNuZXR3b3Jrcy5jb207IHNmZWxkbWFAZ21haWwuY29tOyBz
ZEBxdWVhc3lzbmFpbC5uZXQ7IEVyYW4gQmVuIEVsaXNoYQ0KPiA8ZXJhbmJlQG1lbGxhbm94LmNv
bT47IGFzdEBwbHVtZ3JpZC5jb207IGVkdW1hemV0QGdvb2dsZS5jb207IGhhbm5lc0BzdHJlc3Np
bmR1a3Rpb24ub3JnOyBmLmZhaW5lbGxpQGdtYWlsLmNvbTsNCj4gZHNhQGN1bXVsdXNuZXR3b3Jr
cy5jb20NCj4gU3ViamVjdDogUmU6IFtwYXRjaCBuZXQtbmV4dCB2OCAyLzNdIG5ldDogY29yZTog
QWRkIG9mZmxvYWQgc3RhdHMgdG8gaWZfc3RhdHNfbXNnDQo+IA0KPiANCj4gPiBPbiBTZXAgOSwg
MjAxNiwgYXQgNDozNiBQTSwgTmlrb2xheSBBbGVrc2FuZHJvdiA8bmlrb2xheUBjdW11bHVzbmV0
d29ya3MuY29tPiB3cm90ZToNCj4gPg0KPiA+Pg0KPiA+PiBPbiBTZXAgOCwgMjAxNiwgYXQgOTox
OSBBTSwgSmlyaSBQaXJrbyA8amlyaUByZXNudWxsaS51cz4gd3JvdGU6DQo+ID4+DQo+ID4+IEZy
b206IE5vZ2FoIEZyYW5rZWwgPG5vZ2FoZkBtZWxsYW5veC5jb20+DQo+ID4+DQo+ID4+IEFkZCBh
IG5lc3RlZCBhdHRyaWJ1dGUgb2Ygb2ZmbG9hZCBzdGF0cyB0byBpZl9zdGF0c19tc2cNCj4gPj4g
bmFtZWQgSUZMQV9TVEFUU19MSU5LX09GRkxPQURfWFNUQVRTLg0KPiA+PiBVbmRlciBpdCwgYWRk
IFNXIHN0YXRzLCBtZWFuaW5nIHN0YXRzIG9ubHkgcGVyIHBhY2tldHMgdGhhdCB3ZW50IHZpYQ0K
PiA+PiBzbG93cGF0aCB0byB0aGUgY3B1LCBuYW1lZCBJRkxBX09GRkxPQURfWFNUQVRTX0NQVV9I
SVQuDQo+ID4+DQo+ID4+IFNpZ25lZC1vZmYtYnk6IE5vZ2FoIEZyYW5rZWwgPG5vZ2FoZkBtZWxs
YW5veC5jb20+DQo+ID4+IFNpZ25lZC1vZmYtYnk6IEppcmkgUGlya28gPGppcmlAbWVsbGFub3gu
Y29tPg0KPiA+PiAtLS0NCj4gPj4gaW5jbHVkZS91YXBpL2xpbnV4L2lmX2xpbmsuaCB8ICA5ICsr
KysNCj4gPj4gbmV0L2NvcmUvcnRuZXRsaW5rLmMgICAgICAgICB8IDk3ICsrKysrKysrKysrKysr
KysrKysrKysrKysrKysrKysrKysrKysrKysrKy0tDQo+ID4+IDIgZmlsZXMgY2hhbmdlZCwgMTAy
IGluc2VydGlvbnMoKyksIDQgZGVsZXRpb25zKC0pDQo+ID4+DQo+ID4gW3NuaXBdDQo+ID4+IEBA
IC0zNjU1LDYgKzM3MjUsMjIgQEAgc3RhdGljIGludCBydG5sX2ZpbGxfc3RhdHNpbmZvKHN0cnVj
dCBza19idWZmICpza2IsIHN0cnVjdCBuZXRfZGV2aWNlICpkZXYsDQo+ID4+IAkJfQ0KPiA+PiAJ
fQ0KPiA+Pg0KPiA+PiArCWlmIChzdGF0c19hdHRyX3ZhbGlkKGZpbHRlcl9tYXNrLCBJRkxBX1NU
QVRTX0xJTktfT0ZGTE9BRF9YU1RBVFMsDQo+ID4+ICsJCQkgICAgICppZHhhdHRyKSkgew0KPiA+
PiArCQlhdHRyID0gbmxhX25lc3Rfc3RhcnQoc2tiLCBJRkxBX1NUQVRTX0xJTktfT0ZGTE9BRF9Y
U1RBVFMpOw0KPiA+PiArCQlpZiAoIWF0dHIpDQo+ID4+ICsJCQlnb3RvIG5sYV9wdXRfZmFpbHVy
ZTsNCj4gPj4gKw0KPiA+PiArCQllcnIgPSBydG5sX2dldF9vZmZsb2FkX3N0YXRzKHNrYiwgZGV2
KTsNCj4gPj4gKwkJaWYgKGVyciA9PSAtRU5PREFUQSkNCj4gPj4gKwkJCW5sYV9uZXN0X2NhbmNl
bChza2IsIGF0dHIpOw0KPiA+PiArCQllbHNlDQo+ID4+ICsJCQlubGFfbmVzdF9lbmQoc2tiLCBh
dHRyKTsNCj4gPj4gKw0KPiA+PiArCQlpZiAoKGVycikgJiYgKGVyciAhPSAtRU5PREFUQSkpDQo+
ID4+ICsJCQlnb3RvIG5sYV9wdXRfZmFpbHVyZTsNCj4gPj4gKwl9DQo+ID4+ICsNCj4gPg0KPiA+
IEhtbSwgYWN0dWFsbHkgb24gYSBzZWNvbmQgcmVhZCBJIHRoaW5rIHRoZXJl4oCZcyBhIHBvdGVu
dGlhbCBwcm9ibGVtIGhlcmUuIFNpbmNlIHlvdSBkb27igJl0IHNldCAqaWR4YXR0ciBhbmQgaWYg
dGhlIHNwYWNlDQo+ID4gaXNu4oCZdCBlbm91Z2ggdGhlIGR1bXAgd2lsbCBnZXQgcmVzdGFydGVk
IGFuZCB0aGlzIHdpbGwgbGVhZCB0byBhbiBpbmZpbml0ZSBsb29wLg0KPiANCj4gRXJyLCBwb29y
IGNob2ljZSBvZiB3b3Jkcy4gSSBtZWFudCB0aGUgbG9vcCB3aWxsIGJlIGZvciB1c2Vyc3BhY2Ug
c2luY2UgdGhlIGR1bXAgd2lsbCBlcnIgb3V0IGF0IHRoZSBzYW1lIHNwb3QgYWxsIHRoZSB0aW1l
IHNvIGl0DQo+IHdvbuKAmXQgYmUgYWJsZSB0byBldmVyIGZpbmlzaC4gOi0pDQo+IA0KPiA+IEku
ZS4gaWYgdGhlIHByZXZpb3VzIGF0dHJpYnV0ZXMgZmlsbGVkIHRoZSBza2IgYW5kIHRoZXJl4oCZ
cyBub3QgZW5vdWdoIHJvb20gZm9yIHRoaXMgb25lLCBpdCB3aWxsIHJldHVybiBhbiBlcnJvcg0K
PiA+IGJ1dCAqaWR4YXR0ciB3aWxsIGJlID09IDAgZnJvbSB0aGUgcHJldmlvdXMgYXR0cmlidXRl
IHRodXMgdGhlIHdob2xlIGR1bXAgd2lsbCBiZSByZXN0YXJ0ZWQgKHRoaXMgaXMgaW4gY2FzZSBz
b21lb25lDQo+ID4gcmVxdWVzdHMgdGhpcyBhdHRyaWJ1dGUgd2l0aCBzb21lIG9mIHRoZSBvdGhl
cnMgb2YgY291cnNlKS4NCj4gPg0KPiA+IENoZWVycywNCj4gPiBOaWsNCj4gPg0KPiA+DQoNCkkn
bGwgZml4IGl0LiBUaGFua3MuDQoNCj4gPj4gCW5sbXNnX2VuZChza2IsIG5saCk7DQo+ID4+DQo+
ID4+IAlyZXR1cm4gMDsNCj4gPj4gQEAgLTM3MTIsNiArMzc5OCw5IEBAIHN0YXRpYyBzaXplX3Qg
aWZfbmxtc2dfc3RhdHNfc2l6ZShjb25zdCBzdHJ1Y3QgbmV0X2RldmljZSAqZGV2LA0KPiA+PiAJ
CX0NCj4gPj4gCX0NCj4gPj4NCj4gPj4gKwlpZiAoc3RhdHNfYXR0cl92YWxpZChmaWx0ZXJfbWFz
aywgSUZMQV9TVEFUU19MSU5LX09GRkxPQURfWFNUQVRTLCAwKSkNCj4gPj4gKwkJc2l6ZSArPSBy
dG5sX2dldF9vZmZsb2FkX3N0YXRzX3NpemUoZGV2KTsNCj4gPj4gKw0KPiA+PiAJcmV0dXJuIHNp
emU7DQo+ID4+IH0NCj4gPj4NCj4gPj4gLS0NCj4gPj4gMi41LjUNCg0K
