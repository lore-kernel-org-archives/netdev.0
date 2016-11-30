From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: Aw: Re: [PATCH] mlx4: give precise rx/tx bytes/packets counters
Date: Wed, 30 Nov 2016 15:28:02 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB0230455@AcuExch.aculab.com>
References: <1480088780.8455.543.camel@edumazet-glaptop3.roam.corp.google.com>
         <063D6719AE5E284EB5DD2968C1650D6DB0228849@AcuExch.aculab.com>
         <1480090590.8455.549.camel@edumazet-glaptop3.roam.corp.google.com>
         <trinity-a100658c-7fd5-47b3-ab3f-1f0a80774ccc-1480091457793@3capp-gmx-bs57>
         <1480101551.8455.557.camel@edumazet-glaptop3.roam.corp.google.com>
         <b58286a4-d97f-18dd-e5bd-0f69d3746b81@gmx.de>
 <1480378759.18162.105.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>
To: 'Eric Dumazet' <eric.dumazet@gmail.com>,
        Lino Sanfilippo <LinoSanfilippo@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.193]:59582 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756551AbcK3P2K (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 10:28:10 -0500
In-Reply-To: <1480378759.18162.105.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyBEdW1hemV0DQo+IFNlbnQ6IDI5IE5vdmVtYmVyIDIwMTYgMDA6MTkNCj4gT24g
TW9uLCAyMDE2LTExLTI4IGF0IDIzOjAyICswMTAwLCBMaW5vIFNhbmZpbGlwcG8gd3JvdGU6DQo+
ID4gSGkgRXJpYywNCj4gPg0KPiA+IE9uIDI1LjExLjIwMTYgMjA6MTksIEVyaWMgRHVtYXpldCB3
cm90ZToNCj4gPiA+IE9uIEZyaSwgMjAxNi0xMS0yNSBhdCAxNzozMCArMDEwMCwgTGlubyBTYW5m
aWxpcHBvIHdyb3RlOg0KPiA+ID4+IEhpLA0KPiA+ID4+DQo+ID4gPj4NCj4gPiA+PiA+DQo+ID4g
Pj4gPiBUaGUgUkVBRF9PTkNFKCkgYXJlIGRvY3VtZW50aW5nIHRoZSBmYWN0IHRoYXQgbm8gbG9j
ayBpcyB0YWtlbiB0byBmZXRjaA0KPiA+ID4+ID4gdGhlIHN0YXRzLCB3aGlsZSBhbm90aGVyIGNw
dXMgbWlnaHQgYmVpbmcgY2hhbmdpbmcgdGhlbS4NCj4gPiA+PiA+DQo+ID4gPj4gPiBJIGhhZCBu
byBhbnN3ZXIgeWV0IGZyb20gaHR0cHM6Ly9wYXRjaHdvcmsub3psYWJzLm9yZy9wYXRjaC82OTg0
NDkvDQo+ID4gPj4gPg0KPiA+ID4+ID4gU28gSSB0aG91Z2h0IGl0IHdhcyBub3QgbmVlZGVkIHRv
IGV4cGxhaW4gdGhpcyBpbiB0aGUgY2hhbmdlbG9nLCBnaXZlbg0KPiA+ID4+ID4gdGhhdCBpdCBh
cHBhcmVudGx5IGlzIG9uZSBvZiB0aGUgZmV3IHRoaW5ncyB0aGF0IGNhbiBibG9jayBzb21lb25l
IHRvDQo+ID4gPj4gPiB1bmRlcnN0YW5kIG9uZSBvZiBteSBjaGFuZ2VzIDovDQo+ID4gPj4gPg0K
PiA+ID4+ID4gQXBwYXJlbnRseSBub2JvZHkgcmVhbGx5IHVuZGVyc3RhbmRzIFJFQURfT05DRSgp
IHB1cnBvc2UsIGl0IGlzIHJlYWxseSBhDQo+ID4gPj4gPiBwaXR5IHdlIGhhdmUgdG8gZXhwbGFp
biB0aGlzIG92ZXIgYW5kIG92ZXIuDQo+ID4gPj4gPg0KPiA+ID4+DQo+ID4gPj4gRXZlbiBhdCB0
aGUgcmlzayBvZiBzaG93aW5nIG9uY2UgbW9yZSBhIGxhY2sgb2YgdW5kZXJzdGFuZGluZyBmb3IN
Cj4gPiA+PiBSRUFEX09OQ0UoKToNCj4gPiA+PiBEb2VzIG5vdCBhIFJFQURfT05DRSgpIGhhdmUg
dG8gZSBwYWlyZWQgd2l0aCBzb21lIGtpbmQgb2YNCj4gPiA+PiBXUklURV9PTkNFKCk/DQo+ID4g
Pg0KPiA+ID4gWW91IGFyZSByaWdodC4NCj4gPiA+DQo+ID4gPiBBbHRob3VnaCBpbiB0aGlzIGNh
c2UsIHRoZSBwcm9kdWNlcnMgYXJlIHVzaW5nIGEgbG9jaywgYW5kIGRvDQo+ID4gPg0KPiA+ID4g
cmluZy0+cGFja2V0cysrOw0KPiA+ID4NCj4gPiA+IFdlIGhvcGVmdWxseSBoYXZlIGNvbXBpbGVy
cy9jcHVzIHRoYXQgZG8gbm90IHB1dCBpbnRlcm1lZGlhdGUgZ2FyYmFnZSBpbg0KPiA+ID4gcmlu
Zy0+cGFja2V0cyB3aGlsZSBkb2luZyB0aGUgaW5jcmVtZW50Lg0KPiA+ID4NCj4gPiA+IE9uZSBw
cm9ibGVtIHdpdGggOg0KPiA+ID4NCj4gPiA+IFdSSVRFX09OQ0UocmluZy0+cGFja2V0cywgcmlu
Zy0+cGFja2V0cyArIDEpOw0KPiA+ID4NCj4gPiA+IGlzIHRoYXQgZ2NjIG5vIGxvbmdlciB1c2Vz
IGFuIElOQyBpbnN0cnVjdGlvbi4NCj4gPg0KPiA+IEkgc2VlLiBTbyB3ZSB3b3VsZCBoYXZlIHRv
IGRvIHNvbWV0aGluZyBsaWtlDQo+ID4NCj4gPiB0bXAgPSByaW5nLT5wYWNrZXRzOw0KPiA+IHRt
cCsrOw0KPiA+IFdSSVRFX09OQ0UocmluZy0+cGFja2V0cywgdG1wKTsNCj4gDQo+IA0KPiBXZWxs
LCBnY2Mgd2lsbCBnZW5lcmF0ZSBhIGNvZGUgd2l0aCBtb3JlIGluc3RydWN0aW9ucyB0aGFuIGEg
bWVyZQ0KPiANCj4gImluYyAgb2Zmc2V0KCVyZWdpc3RlcikiDQoNCkFyZSB5b3Ugc3VyZT8/DQpM
YXN0IEkgbG9va2VkIGdjYyBzZWVtZWQgdG8gY29udmVydCAnZm9vKysnIHRvICdmb28gPSBmb28g
KyAxJyBiZWZvcmUNCmdlbmVyYXRpbmcgYW55IGNvZGUuDQpJdCBtaWdodCB0aGVuIG9wdGltaXNl
IHRoYXQgYmFjayB0byBhIG1lbW9yeSBpbmNyZW1lbnQsIGJ1dCB0aGF0IHdvdWxkDQphbHNvIGhh
cHBlbiBpZiB5b3UnZCBjb2RlZCB0aGUgbGF0dGVyIGZvcm0uDQoNCj4gV2hpY2ggaXMga2luZCBv
ZiB1bmZvcnR1bmF0ZSwgZ2l2ZW4gaXQgaXMgdGhlIGZhc3QgcGF0aC4NCj4gDQo+IEJldHRlciBh
ZGQgYSBjb21tZW50LCBsaWtlIDoNCj4gDQo+IC8qIFdlIHNob3VsZCB1c2UgV1JJVEVfT05DRSgp
IHRvIHBhaXIgd2l0aCB0aGUgUkVBRF9PTkNFKCkgZm91bmQgaW4geHh4eCgpDQo+ICAqIEJ1dCBn
Y2Mgd291bGQgZ2VuZXJhdGUgbm9uIG9wdGltYWwgY29kZS4NCj4gICovDQoNCkFjdHVhbGx5IHdo
aWxlIFJFQURfT05DRSgpIGlzIGdlbmVyYWxseSB1c2VmdWwgLSB0byBnZXQgYSBzbmFwc2hvdCBv
ZiBhIGNoYW5naW5nIHZhbHVlLg0KDQpXUklURV9PTkNFKCkgaXNuJ3QgYSBwYWlyaW5nIC0gdGhl
IGNvbXBpbGVyIGlzIGhpZ2hseSB1bmxpa2VseSB0byB3cml0ZSBhDQpsb2NhdGlvbiB0d2ljZS4N
CllvdSBtaWdodCB3YW50IGFuIGFubm90YXRpb24gdG8gZW5zdXJlIGlzIGRvZXNuJ3QgYXNzdW1l
IGl0IGNhbiByZWFkIHRoZSB2YWx1ZQ0KYmFjayAod3JpdGUgdGhyb3VnaCB2b2xhdGlsZSBwb2lu
dGVyKS4gQnV0IHRoYXQgaGFzIG5vdGhpbmcgdG8gZG8gd2l0aCBob3cgcmVhZGVycyBiZWhhdmUu
DQoNCglEYXZpZA0KDQo=
