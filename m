From: Ilan Tayari <ilant@mellanox.com>
Subject: RE: [PATCH] net/mlx5: IPSec, fix 64-bit division correctly
Date: Mon, 10 Jul 2017 10:24:25 +0000
Message-ID: <AM4PR0501MB194094863514236D1BE04C62DBA90@AM4PR0501MB1940.eurprd05.prod.outlook.com>
References: <20170710093842.2921914-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Matan Barak <matanb@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>,
        Yossi Kuperman <yossiku@mellanox.com>,
        Yevgeny Kliteynik <kliteyn@mellanox.com>,
        Boris Pismenny <borisp@mellanox.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>, Saeed Mahameed <saeedm@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170710093842.2921914-1-arnd@arndb.de>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBBcm5kIEJlcmdtYW5uIFttYWls
dG86YXJuZEBhcm5kYi5kZV0NCj4gU3ViamVjdDogW1BBVENIXSBuZXQvbWx4NTogSVBTZWMsIGZp
eCA2NC1iaXQgZGl2aXNpb24gY29ycmVjdGx5DQo+IA0KPiBUaGUgbmV3IElQU2VjIG9mZmxvYWQg
Y29kZSBpbnRyb2R1Y2VkIGEgYnVpbGQgZXJyb3I6DQo+IA0KPiBkcml2ZXJzL25ldC9ldGhlcm5l
dC9tZWxsYW5veC9tbHg1L2NvcmUvZW5fYWNjZWwvaXBzZWNfcnh0eC5vOiBJbiBmdW5jdGlvbg0K
PiBgbWx4NWVfaXBzZWNfYnVpbGRfaW52ZXJzZV90YWJsZSc6DQo+IGlwc2VjX3J4dHguYzooLnRl
eHQrMHg1NTYpOiB1bmRlZmluZWQgcmVmZXJlbmNlDQo+IA0KPiBBbm90aGVyIHBhdGNoIHdhcyBh
ZGRlZCBvbiB0b3AgdG8gZml4IHRoZSBidWlsZCBlcnJvciwgYnV0DQo+IHRoYXQgaW50cm9kdWNl
ZCBhIG5ldyBidWcsIGFzIHdlIG5vdyB1c2UgdGhlIHJlbWFpbmRlciBvZg0KPiB0aGUgZGl2aXNp
b24gcmF0aGVyIHRoYW4gdGhlIHJlc3VsdC4NCj4gDQo+IFRoaXMgbWFrZXMgaXQgdXNlIHRoZSBj
b3JyZWN0IGhlbHBlciBmdW5jdGlvbiBpbnN0ZWFkLg0KPiANCj4gRml4ZXM6IDVkZmQ4N2I2N2Nk
OSAoIm5ldC9tbHg1OiBJUFNlYywgRml4IDY0LWJpdCBkaXZpc2lvbiBvbiAzMi1iaXQNCj4gYnVp
bGRzIikNCj4gRml4ZXM6IDJhYzljZmU3ODIyMyAoIm5ldC9tbHg1ZTogSVBTZWMsIEFkZCBJbm5v
dmEgSVBTZWMgb2ZmbG9hZCBUWCBkYXRhDQo+IHBhdGgiKQ0KPiBTaWduZWQtb2ZmLWJ5OiBBcm5k
IEJlcmdtYW5uIDxhcm5kQGFybmRiLmRlPg0KDQpUaGlzIGlzIGEgZ29vZCBmaXguIFZhbHVlcyBh
cmUgbm93IGdlbmVyYXRlZCBjb3JyZWN0bHkuDQpTb3JyeSBmb3IgdGhlIG1peHVwLg0KDQpUaGFu
ayB5b3UgQXJuZCENCg0KUmV2aWV3ZWQtYnk6IElsYW4gVGF5YXJpIDxpbGFudEBtZWxsYW5veC5j
b20+DQoNCg==
