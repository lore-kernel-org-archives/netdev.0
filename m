From: Ilan Tayari <ilant@mellanox.com>
Subject: RE: [for-next 4/6] net/mlx5: FPGA, Add basic support for Innova
Date: Sun, 28 May 2017 07:24:19 +0000
Message-ID: <AM4PR0501MB19406FF2555888457C00E217DBF20@AM4PR0501MB1940.eurprd05.prod.outlook.com>
References: <20170523114404.20387-1-saeedm@mellanox.com>
 <20170523114404.20387-5-saeedm@mellanox.com>
 <20170524165059.42lmrwzzcxvi2sf7@ast-mbp>
 <AM4PR0501MB1940885C2F1CEF4DDE4EA8D1DBFF0@AM4PR0501MB1940.eurprd05.prod.outlook.com>
 <CALzJLG-B_tAmASn_SMmPNiucq-tTpywHniRTkb4N32oGF6Y3Ng@mail.gmail.com>
 <00716e5a-8b51-0b3f-a1b8-1bb7b346a66a@fb.com>
 <CALzJLG9YNpagdJAcrh6O0jJhZWtsck6KigRtVxyjkArTm=82ew@mail.gmail.com>
 <f47d7519-4f58-bc94-2387-20342afd91b8@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>
To: Jes Sorensen <jsorensen@fb.com>,
        Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr10044.outbound.protection.outlook.com ([40.107.1.44]:44724
        "EHLO EUR02-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750820AbdE1HYX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 28 May 2017 03:24:23 -0400
In-Reply-To: <f47d7519-4f58-bc94-2387-20342afd91b8@fb.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBKZXMgU29yZW5zZW4gW21haWx0
bzpqc29yZW5zZW5AZmIuY29tXQ0KPiANCj4gT24gMDUvMjYvMjAxNyAwNDoyOSBBTSwgU2FlZWQg
TWFoYW1lZWQgd3JvdGU6DQo+ID4gT24gVGh1LCBNYXkgMjUsIDIwMTcgYXQgMTE6NDggUE0sIEpl
cyBTb3JlbnNlbiA8anNvcmVuc2VuQGZiLmNvbT4gd3JvdGU6DQo+ID4+IE9uIDA1LzI1LzIwMTcg
MDY6NDAgQU0sIFNhZWVkIE1haGFtZWVkIHdyb3RlOg0KPiA+IEhpIEplcywNCj4gPg0KPiA+IE5v
LCBJdCBpcyBjbGVhcmx5IHN0YXRlZCBpbiB0aGUgY29tbWl0IG1lc3NhZ2UgOg0KPiA+DQo+ID4g
IlRoZSBGUEdBIGlzIGEgYnVtcC1vbi10aGUtd2lyZSBhbmQgdGh1cyBhZmZlY3RzIG9wZXJhdGlv
biBvZg0KPiA+IHRoZSBtbHg1X2NvcmUgZHJpdmVyIG9uIHRoZSBDb25uZWN0WCBBU0lDLiINCj4g
Pg0KPiA+IFdoaWNoIG1lYW5zIG1seDUgRlBHQSB1c2VyIGNhbiBvbmx5IHdyaXRlIGxvZ2ljIHdo
aWNoIGFmZmVjdHMgb25seQ0KPiA+IHBhY2tldHMgZ29pbmcgaW4vb3V0DQo+ID4gQSBDb25uZWN0
WCBjaGlwIC0gc28gaXQgaXMgb25seSBuZXR3b3JrIHN0dWZmIC0uDQo+ID4NCj4gPj4gV2UgaGF2
ZSB0aGlzIHdpdGggb3RoZXIgZGV2aWNlcyBpbiB0aGUga2VybmVsIHdoZXJlIGEgcHJpbWFyeSBk
ZXZpY2UNCj4gZHJpdmVyDQo+ID4+IHByb3ZpZGVzIGFuIGludGVyZmFjZSBmb3IgYW4gYWRkaXRp
b25hbCBzdWItZHJpdmVyIHRvIGFjY2VzcyBhbm90aGVyDQo+IGRldmljZQ0KPiA+PiBiZWhpbmQg
aXQuIExpa2UgYnQtY29leGlzdCBpbiBzb21lIG9mIHRoZSB3aWZpIGRyaXZlcnMgYWxsb3dpbmcg
YWNjZXNzDQo+IHRvIGENCj4gPj4gYmx1ZXRvb3RoIGRldmljZSBiZWhpbmQgaXQuDQo+ID4NCj4g
PiBCbHV0b290aCBvdmVyIHdpZmkgb3IgdmlzZSB2ZXJzYSBpcyBhIHZlcnkgZ29vZCBleGFtcGxl
IHRvIHdoYXQgeW91DQo+ID4gYXJlIHJlcXVlc3RpbmcuDQo+ID4gQnV0LCBpdCBkb2Vzbid0IGZp
dCB0byB3aGF0IHdlIGFyZSB0cnlpbmcgdG8gZG8gaGVyZS4gbWx4NSBGR1BBIGlzIGENCj4gPiBD
b25uZWN0WCBjYXJkIGZlYXR1cmUsIG5vdCBhIG5ldyBwcm90b2NvbC4NCj4gDQo+IEluIHRoYXQg
Y2FzZSBpdCB3b3VsZCBuZWVkIHRvIGJlIGFuIG9wdGlvbmFsIG1vZHVsZSB0aGF0IGNhbiBiZSBl
bmFibGVkDQo+IG9yIGRpc2FibGVkIGF0IGJ1aWxkIHRpbWUuDQoNCkplcywNCg0KSXQgaXMgYWxy
ZWFkeSBtb2R1bGFyIGxpa2UgdGhhdC4gU2VlIENPTkZJR19NTFg1X0ZQR0EuDQoNCklsYW4uDQoN
Cj4gDQo+IENoZWVycywNCj4gSmVzDQo+IA0KDQo=
