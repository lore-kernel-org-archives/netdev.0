From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next 3/3] ipvlan: Introduce l3s mode
Date: Sat, 10 Sep 2016 11:11:40 -0700 (PDT)
Message-ID: <20160910.111140.1065918968661149789.davem@davemloft.net>
References: <ddb5c5e8-6656-754a-8178-09096a2d333e@cumulusnetworks.com>
        <CAF2d9jj35YjaAJ4ziUSBFdgakhMY3o8M=VHU4bOfzWA=e0k_0Q@mail.gmail.com>
        <7c134452-368e-96f9-c0b1-0f6d2e507bc5@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: base64
Cc: maheshb@google.com, mahesh@bandewar.net, netdev@vger.kernel.org,
        edumazet@google.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45370 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754945AbcIJSLu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Sep 2016 14:11:50 -0400
In-Reply-To: <7c134452-368e-96f9-c0b1-0f6d2e507bc5@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRGF2aWQgQWhlcm4gPGRzYUBjdW11bHVzbmV0d29ya3MuY29tPg0KRGF0ZTogU2F0LCAx
MCBTZXAgMjAxNiAxMDoyNToyNyAtMDYwMA0KDQo+IE9uIDkvOS8xNiA0OjQ2IFBNLCBNYWhlc2gg
QmFuZGV3YXIgKOCkruCkueClh+CktiDgpKzgpILgpKHgpYfgpLXgpL7gpLApIHdyb3RlOg0KPj4g
T24gRnJpLCBTZXAgOSwgMjAxNiBhdCAzOjI2IFBNLCBEYXZpZCBBaGVybiA8ZHNhQGN1bXVsdXNu
ZXR3b3Jrcy5jb20+IHdyb3RlOg0KPj4+IE9uIDkvOS8xNiAzOjUzIFBNLCBNYWhlc2ggQmFuZGV3
YXIgd3JvdGU6DQo+Pj4+IGRpZmYgLS1naXQgYS9kcml2ZXJzL25ldC9LY29uZmlnIGIvZHJpdmVy
cy9uZXQvS2NvbmZpZw0KPj4+PiBpbmRleCAwYzU0MTViMDVlYTkuLjk1ZWRkMTczN2FiNSAxMDA2
NDQNCj4+Pj4gLS0tIGEvZHJpdmVycy9uZXQvS2NvbmZpZw0KPj4+PiArKysgYi9kcml2ZXJzL25l
dC9LY29uZmlnDQo+Pj4+IEBAIC0xNDksNiArMTQ5LDcgQEAgY29uZmlnIElQVkxBTg0KPj4+PiAg
ICAgIHRyaXN0YXRlICJJUC1WTEFOIHN1cHBvcnQiDQo+Pj4+ICAgICAgZGVwZW5kcyBvbiBJTkVU
DQo+Pj4+ICAgICAgZGVwZW5kcyBvbiBJUFY2DQo+Pj4+ICsgICAgc2VsZWN0IE5FVF9MM19NQVNU
RVJfREVWDQo+Pj4NCj4+PiBkZXBlbmRzIG9uIGluc3RlYWQgb2Ygc2VsZWN0Pw0KPj4gDQo+PiBU
aGUga2J1aWxkL2tjb25maWctbGFuZ3VhZ2UudHh0IHN1Z2dlc3RzIHRoYXQgZm9yICJkZXBlbmRz
IG9uIiB0aGUNCj4+IG9wdGlvbiBfbXVzdF8gYmUgc2VsZWN0ZWQgb3RoZXJ3aXNlIG1lbnVjb25m
aWcgd29udCBldmVuIHByZXNlbnQgdGhlDQo+PiBkZXBlbmRlbnQgb3B0aW9uIHdoaWxlIHNlbGVj
dCBwb3NpdGl2ZWx5IHNldHMgdGhlIG9wdGlvbi4NCj4gDQo+IHVuZGVyc3Rvb2QuIFZSRiBkcml2
ZXIgdXNlcyAnZGVwZW5kcyBvbicNCg0KU2VsZWN0IGlzIGZvciB0aGluZ3MgdGhhdCBhcmUgbGFy
Z2VseSBpbnZpc2libGUgdG8gdGhlIHVzZXIuICBJdCBpcyBtb3JlIG9mDQphIGJydXRlIGZvcmNl
IHRvb2wgdGhhdCBoYXMgc2V2ZXJhbCBsaW1pdGF0aW9ucy4gIEZvciBvbmUsIGl0IGRvZXNuJ3QN
CnJlY3Vyc2l2ZWx5IGFwcGx5IGRlcGVuZGVuY2llcyBvZiB0aGUgdGhpbmcgeW91IHNlbGVjdGVk
LiAgVGhpcyBtYWtlcyBpdA0KcXVpdGUgdHJpdmlhbCB0byBjcmVhdGUgc2l0dWF0aW9ucyB3aGVy
ZSB5b3Ugc2VsZWN0IFggYnV0IGl0IGFjdHVhbGx5DQpjYW4ndCB3b3JrIGJlY2F1c2UgaXQncyAi
ZGVwZW5kIiBzdGF0ZW1lbnRzIGFyZW4ndCBzYXRpc3RmaWVkLg0KDQpEZXBlbmQgaXMgcmVhbGx5
IHRoZSB0aGluZyB5b3Ugb3VnaHQgdG8gdXNlLCBhbmQgeWVzIHRoaXMgbWVhbnMgdGhhdCB0aGUN
CnVzZXIgaGFzIHRvIGtub3cgdG8gZW5hYmxlIHRoZSB0aGluZyB5b3UgZGVwZW5kIHVwb24gdG8g
bWFrZSB5b3VyIGZlYXR1cmUNCmF2YWlsYWJsZS4gIEJ1dCB0aGF0J3MganVzdCBob3cgaXQgd29y
a3MuDQo=
