From: Chris Brandt <Chris.Brandt@renesas.com>
Subject: RE: [PATCH] net: ethernet: renesas: sh_eth: do not access POST
 registers if not exist
Date: Tue, 30 Aug 2016 14:16:41 +0000
Message-ID: <SG2PR06MB1165DAEF1E16FFA7E2DC49308AE00@SG2PR06MB1165.apcprd06.prod.outlook.com>
References: <20160826200107.20681-1-chris.brandt@renesas.com>
 <87690577-4526-ce66-6ce3-68ac8b20e737@cogentembedded.com>
 <SG2PR06MB11653F9E20F38972CA11EF328AE10@SG2PR06MB1165.apcprd06.prod.outlook.com>
 <f456cca3-289c-67dc-f15c-5b475553cdde@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Simon Horman <horms+renesas@verge.net.au>,
        Geert Uytterhoeven <geert+renesas@glider.be>,
        Daniel Palmer <daniel@0x0f.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-renesas-soc@vger.kernel.org"
        <linux-renesas-soc@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <f456cca3-289c-67dc-f15c-5b475553cdde@cogentembedded.com>
Content-Language: en-US
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

SGVsbG8gU2VyZ2VpLA0KDQpPbiBBdWcgMjksIDIwMTYsIFNlcmdlaSBTaHR5bHlvdiB3cm90ZToN
Cj4gICAgU0g3NzU3IGlzIG5vdCB0aGUgb25seSBwbGF0Zm9ybSB3aXRoIFRTVSwgdGhlcmUncyBl
LmcuIFI4QTc3NDAgQVJNDQo+IFNvQyB3aGljaCBvbmx5IGhhcyAxIEdFVEhFUiBjaGFubmVsLi4u
DQoNCkkgZG9uJ3QgaGF2ZSB0aGUgUjhBNzc0MCBtYW51YWwgKFItTW9iaWxlIEExKSBzbyBJIGNh
bid0IHNlZS4gQnV0IGV2ZW4gaWYgaXQgZG9lcyBub3QgaGF2ZSB0aGUgUE9TVCByZWdpc3RlcnMs
IGl0IG1pZ2h0IG5vdCBodXJ0IGFueXRoaW5nLg0KDQpJIGp1c3QgbG9va2VkIGF0IHRoZSBSWi9B
MSByZWdpc3RlciBzcGFjZSBhbmQgdGhlcmUgc2VlbXMgdG8gYmUgZHVtbXkgcmVnaXN0ZXJzIGlu
IHRoZSBQT1NUMS00IGFyZWEuIEkgY2FuIHdyaXRlIHRvIHRoZW0gYW5kIHJlYWQgYmFjayB3aGF0
IEkgd3JvdGUuLi53aGljaCBpcyBhbGwgdGhhdCB0aGUgc2hfZXRoIGRyaXZlciBjYXJlcyBhYm91
dC4gSSBiZXQgd2hlbiB0aGUgZGVzaWduZXJzIGJyaW5nIGluIHRoZSBFdGhlckMgSVAgYmxvY2ss
IHRoZSBlbnRpcmUgcmVnaXN0ZXIgYWRkcmVzcyBpcyBhbHdheXMgcG9wdWxhdGVkIHdpdGggYSBz
aW1wbGUgbGF0Y2ggcmVnaXN0ZXJzLiBBbmQgdGhlbiwgaWYgYSBmZWF0dXJlIGlzIG5vdCBpbmNs
dWRlZCAobGlrZSByZWxheS9QT1NUKSwgdGhlbiBub3RoaW5nIGlzIGhvb2tlZCB1cCBvbiB0aGUg
YmFjayBzaWRlIG9mIGl0Lg0KDQpTbywgdGhlICdlYXNpZXN0JyBzb2x1dGlvbiBpcyB0byBqdXN0
IHB1dCB0aGUgcmVnaXN0ZXJzIGludG8gdGhlIHNoX2V0aF9vZmZzZXRfZmFzdF9yeiBhcnJheSBh
bmQgbm90IHRyeSB0byBtYWtlIHRoaW5ncyBtb3JlIGNvbXBsaWNhdGVkLg0KCVtUU1VfVEVOXQk9
IDB4MDA2NCwNCisJW1RTVV9QT1NUMV0JPSAweDAwNzAsDQorCVtUU1VfUE9TVDJdCT0gMHgwMDc0
LA0KKwlbVFNVX1BPU1QzXQk9IDB4MDA3OCwNCisJW1RTVV9QT1NUNF0JPSAweDAwN2MsDQoNCg0K
Q2hyaXMNCg0K
