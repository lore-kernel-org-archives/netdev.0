From: Chris Brandt <Chris.Brandt@renesas.com>
Subject: RE: [PATCH] net: ethernet: renesas: sh_eth: do not access POST
 registers if not exist
Date: Thu, 8 Sep 2016 14:27:31 +0000
Message-ID: <SG2PR06MB116564DD88FD22D59E7174008AFB0@SG2PR06MB1165.apcprd06.prod.outlook.com>
References: <20160826200107.20681-1-chris.brandt@renesas.com>
 <87690577-4526-ce66-6ce3-68ac8b20e737@cogentembedded.com>
 <SG2PR06MB11653F9E20F38972CA11EF328AE10@SG2PR06MB1165.apcprd06.prod.outlook.com>
 <f456cca3-289c-67dc-f15c-5b475553cdde@cogentembedded.com>
 <SG2PR06MB1165DAEF1E16FFA7E2DC49308AE00@SG2PR06MB1165.apcprd06.prod.outlook.com>
 <CAMuHMdXhSUbP+81K_1vRxvkqecQM2Pn0z5dPOmBQAfqBykdxGg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "David S . Miller" <davem@davemloft.net>,
        Simon Horman <horms+renesas@verge.net.au>,
        Geert Uytterhoeven <geert+renesas@glider.be>,
        Daniel Palmer <daniel@0x0f.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-renesas-soc@vger.kernel.org"
        <linux-renesas-soc@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <CAMuHMdXhSUbP+81K_1vRxvkqecQM2Pn0z5dPOmBQAfqBykdxGg@mail.gmail.com>
Content-Language: en-US
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

QXMgYSBmb2xsb3cgdXAgb24gdGhpcyB0aHJlYWQ6DQoNCg0KT24gOC8zMC8yMDE2LCBHZWVydCBV
eXR0ZXJob2V2ZW4gd3JvdGU6DQo+ID4gSSBqdXN0IGxvb2tlZCBhdCB0aGUgUlovQTEgcmVnaXN0
ZXIgc3BhY2UgYW5kIHRoZXJlIHNlZW1zIHRvIGJlIGR1bW15DQo+ID4gcmVnaXN0ZXJzIGluIHRo
ZSBQT1NUMS00IGFyZWEuIEkgY2FuIHdyaXRlIHRvIHRoZW0gYW5kIHJlYWQgYmFjayB3aGF0IEkN
Cj4gPiB3cm90ZS4uLndoaWNoIGlzIGFsbCB0aGF0IHRoZSBzaF9ldGggZHJpdmVyIGNhcmVzIGFi
b3V0LiBJIGJldCB3aGVuIHRoZQ0KPiA+IGRlc2lnbmVycyBicmluZyBpbiB0aGUgRXRoZXJDIElQ
IGJsb2NrLCB0aGUgZW50aXJlIHJlZ2lzdGVyIGFkZHJlc3MgaXMNCj4gPiBhbHdheXMgcG9wdWxh
dGVkIHdpdGggYSBzaW1wbGUgbGF0Y2ggcmVnaXN0ZXJzLiBBbmQgdGhlbiwgaWYgYSBmZWF0dXJl
IGlzDQo+ID4gbm90IGluY2x1ZGVkIChsaWtlIHJlbGF5L1BPU1QpLCB0aGVuIG5vdGhpbmcgaXMg
aG9va2VkIHVwIG9uIHRoZSBiYWNrIHNpZGUNCj4gPiBvZiBpdC4NCj4gDQo+IFdoYXQgYSB3YXN0
ZSBvZiB0cmFuc2lzdG9ycy4uLg0KPiBUaGVyZSBhcmUgcGxlbnR5IG9mIGhpZGRlbiByZWdpc3Rl
cnMgaW4gbWFueSBJUCBibG9ja3MuDQoNCldlbGwgR2VlcnQsIHR1cm5zIG91dCB0aG9zZSB0cmFu
c2lzdG9ycyB3ZXJlbid0IHdhc3RlZC4gVGhleSBhcmUgdGhlcmUuLi5hbmQgaW4gZmFjdCBhcmUg
bmVlZCB0byBhY3R1YWxseSBtYWtlIHRoZSBzeXN0ZW0gd29yayBjb3JyZWN0bHkuDQoNCkFmdGVy
IHNvbWUgaW52ZXN0aWdhdGlvbiwgbG9va3MgbGlrZSB3aGVuIHNvbWVvbmUgd2FzIGN1dHRpbmcg
b3V0IHVuLW5lZWRlZCBwYWdlcyB0byBtYWtlIHRoZSBSWi9BMSBoYXJkd2FyZSBtYW51YWwgdGhl
eSBtaXN1bmRlcnN0b29kIHdoYXQgdGhvc2UgcmVnaXN0ZXJzIHdlcmUgZm9yLg0KDQpJbiByZWFs
aXR5LCB0aGV5IGp1c3QgbmVlZGVkIHRvIGNvcHkgdGhlIHBhZ2VzIGZyb20gdGhlIFNINzczNCBI
YXJkd2FyZSBtYW51YWwgZm9yIHRoZSBQT1NUMS00LiBBbHNvLCBpZiB5b3UgcmVhZCBhYm91dCB0
aGUgVFNVIGNsb3NlbHkgeW91J2xsIHNlZSB0aGF0IHlvdSBhbHNvIG5lZWQgcmVnaXN0ZXIgRldT
TEMgdG8gYWN0dWFsbHkgZW5hYmxlIHRoZSBQT1NUMS00IHJlZ2lzdGVycyAobW9yZSBvciBsZXNz
KS4NCg0KDQpJJ3ZlIGFscmVhZHkgc3VibWl0dGVkIGEgdjIgcGF0Y2ggd2hpY2ggc2hvdWxkIGJl
IHByZXR0eSBzdHJhaWdodCBmb3J3YXJkIG5vdy4NCg0KDQpDaHJpcw0KDQo=
