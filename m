From: Yevgeny Petrilin <yevgenyp@mellanox.com>
Subject: RE: [PATCH net-next] mlx4: use dev_kfree_skb() instead of
 dev_kfree_skb_any()
Date: Wed, 19 Sep 2012 07:58:13 +0000
Message-ID: <953B660C027164448AE903364AC447D28721B46E@MTLDAG01.mtl.com>
References: <1347866974.26523.53.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: netdev <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	"Ying Cai" <ycai@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog115.obsmtp.com ([207.126.144.139]:55476 "HELO
	eu1sys200aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751519Ab2ISH7g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2012 03:59:36 -0400
In-Reply-To: <1347866974.26523.53.camel@edumazet-glaptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiANCj4gU2luY2UgY29tbWl0IGUyMjk3OWQ5NmE1IChtbHg0X2VuOiBNb3ZpbmcgdG8gSW50ZXJy
dXB0cyBmb3IgVFgNCj4gY29tcGxldGlvbnMpLCB3ZSBubyBsb25nZXIgY2FuIGZyZWUgVFggc2ti
IGZyb20gaGFyZCBJUlEsIGJ1dCBvbmx5IGZyb20NCj4gbm9ybWFsIHNvZnRpcnEgb3IgcHJvY2Vz
cyBjb250ZXh0Lg0KPiANCj4gVGhlcmVmb3JlLCB3ZSBjYW4gZGlyZWN0bHkgY2FsbCBkZXZfa2Zy
ZWVfc2tiKCkgZnJvbQ0KPiBtbHg0X2VuX2ZyZWVfdHhfZGVzYygpIGxpa2Ugb3RoZXIgY29udmVu
dGlvbmFsIE5BUEkgZHJpdmVycy4NCj4gDQoNCkhpIEVyaWMsDQpBdCB0aGUgbW9tZW50IHRoZSBU
WCBjb21wbGV0aW9uIHByb2Nlc3NpbmcgaXMgZG9uZSBmcm9tIElSUSBjb250ZXh0Lg0KU28gSSB0
aGluayB3ZSBuZWVkIHRvIGNoYW5nZSB0aGUgZHJpdmVyIHRvIHdvcmsgd2l0aCBOQVBJIGZvciBU
WCBjb21wbGV0aW9ucw0KYmVmb3JlIG1ha2luZyB0aGlzIGNoYW5nZS4NCg0KSSdsbCBzZW5kIHRo
ZSBwYXRjaCBpbiBhIGZldyBkYXlzLg0KDQpZZXZnZW55DQo=
