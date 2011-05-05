From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: RE: [PATCH] mlx4_en: Setting RSS hash result to skb->rxhash field
Date: Thu, 5 May 2011 07:08:06 +0000
Message-ID: <953B660C027164448AE903364AC447D2070B8E9C@mtldag01.mtl.com>
References: <4DC156AF.4050807@mellanox.co.il>
	 <1304520260.3203.34.camel@localhost>
	 <1304527586.32152.5.camel@edumazet-laptop>
	 <953B660C027164448AE903364AC447D2070B8E35@mtldag01.mtl.com>
	 <1304578518.32152.794.camel@edumazet-laptop>
 <1304578635.32152.800.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:38105 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751473Ab1EEHIL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 May 2011 03:08:11 -0400
In-Reply-To: <1304578635.32152.800.camel@edumazet-laptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiA+ID4gPg0KPiA+ID4gRXJpYywgeW91IGFyZSBjb3JyZWN0Lg0KPiA+ID4gV2UgZG8gcGxhbiB0
byBlbmFibGUgZnVsbCAzMiBiaXQgaGFzaCBmb3Igb3VyIGRldmljZXMuDQo+ID4gPiBPbmNlIGl0
IGlzIGRvbmUsIHdlIHdpbGwgbmF0dXJhbGx5IHVzZSB0aGUgd2hvbGUgMzIgYml0cy4NCj4gPiA+
IEluIHRoZSBtZWFud2hpbGUsIGV2ZW4gd2l0aCB0aGlzIGNoYW5nZSB3ZSBzZWUgaW1wcm92ZWQg
cGVyZm9ybWFuY2Ugd2hlbiBlbmFibGluZyBSUFMuDQo+ID4NCj4gPiBIbW0sIHRoYXRzIHN0cmFu
Z2UgYmVjYXVzZSB5b3UgaGF2ZSBvbmx5IDI1NiBwb3NzaWJsZSB2YWx1ZXMgZm9yIHJ4aGFzaCwN
Cj4gPiBhbmQgaXQncyBPSyBmb3IgbWF5YmUgb25lIGh1bmRyZWQgZmxvd3MuIChJIGFtIHRhbGtp
bmcgbm90IG9mIFJQUyBidXQNCj4gPiBSRlMgaGVyZSkNCj4gPg0KPiA+IFNvIHlvdXIgcGF0Y2gg
aXMgYSB3aW4gb25seSBmb3Igc21hbGwgaG9zdHMsIG9yIHBhcnRpY3VsYXIgd29ya2xvYWRzDQo+
ID4gKGRpZCBJIHNheSBiaWFzZWQgYmVuY2htYXJrcyA/IDspICkNCj4gPg0KPiA+IFJlYWxseSwg
d2UgYmV0dGVyIHVzZSB0aGUgbGludXgvc29mdHdhcmUgZnVsbCAzMmJpdCByeGhhc2ggaW4gdGhp
cyBjYXNlLA0KPiA+IGFuZCB3YWl0IGZvciB5b3VyIDMyYml0IGZ1bGwgc3VwcG9ydC4NCj4gPg0K
PiA+DQo+IA0KPiBCVFcsIGJlZm9yZSB5b3Ugc3VibWl0IGFub3RoZXIgcnhoYXNoIHBhdGNoLCBw
bGVhc2UgbWFrZSBzdXJlIGV0aHRvb2wNCj4gc3VwcG9ydCBpcyBpbmNsdWRlZC4gQW4gYWRtaW4g
bXVzdCBiZSBhYmxlIHRvIHN3aXRjaCBvZmYgaGFyZHdhcmUNCj4gc3VwcG9ydCA6DQo+IA0KPiBl
dGh0b29sIC1LIGV0aDAgcnhoYXNoIG9mZg0KPiANCj4gDQpUaGFua3MgZm9yIHRoaXMgaW5wdXQN
Cg==
