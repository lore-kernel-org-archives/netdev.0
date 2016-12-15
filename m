From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2 1/4] siphash: add cryptographically secure hashtable
 function
Date: Thu, 15 Dec 2016 15:41:46 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB0240529@AcuExch.aculab.com>
References: <20161214035927.30004-1-Jason@zx2c4.com>
 <CAHmME9q9ffdtWRbzyMO1ktTdtEFdfumTfojTTNLXFhoa+R+MWQ@mail.gmail.com>
 <8ea3fdff-23c4-b81d-2588-44549bd2d8c1@stressinduktion.org>
 <063D6719AE5E284EB5DD2968C1650D6DB02401ED@AcuExch.aculab.com>
 <707472e1-b385-836d-c4c6-791c1dcc0776@stressinduktion.org>
 <063D6719AE5E284EB5DD2968C1650D6DB02402C0@AcuExch.aculab.com>
 <0f3c3694-c00b-aae2-5b08-25bc64bf6372@stressinduktion.org>
 <063D6719AE5E284EB5DD2968C1650D6DB0240437@AcuExch.aculab.com>
 <f6813084-6f46-0b22-e9c3-97b2e266f8f6@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Netdev <netdev@vger.kernel.org>,
        "kernel-hardening@lists.openwall.com"
        <kernel-hardening@lists.openwall.com>,
        Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>,
        LKML <linux-kernel@vger.kernel.org>,
        "Linux Crypto Mailing List" <linux-crypto@vger.kernel.org>,
        "Daniel J . Bernstein" <djb@cr.yp.to>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Eric Biggers <ebiggers3@gmail.com>
To: 'Hannes Frederic Sowa' <hannes@stressinduktion.org>,
        "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <f6813084-6f46-0b22-e9c3-97b2e266f8f6@stressinduktion.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RnJvbTogSGFubmVzIEZyZWRlcmljIFNvd2ENCj4gU2VudDogMTUgRGVjZW1iZXIgMjAxNiAxNDo1
Nw0KPiBPbiAxNS4xMi4yMDE2IDE0OjU2LCBEYXZpZCBMYWlnaHQgd3JvdGU6DQo+ID4gRnJvbTog
SGFubmVzIEZyZWRlcmljIFNvd2ENCj4gPj4gU2VudDogMTUgRGVjZW1iZXIgMjAxNiAxMjo1MA0K
PiA+PiBPbiAxNS4xMi4yMDE2IDEzOjI4LCBEYXZpZCBMYWlnaHQgd3JvdGU6DQo+ID4+PiBGcm9t
OiBIYW5uZXMgRnJlZGVyaWMgU293YQ0KPiA+Pj4+IFNlbnQ6IDE1IERlY2VtYmVyIDIwMTYgMTI6
MjMNCj4gPj4+IC4uLg0KPiA+Pj4+IEhtbT8gRXZlbiB0aGUgSW50ZWwgQUJJIGV4cGVjdHMgYWxp
Z25tZW50IG9mIHVuc2lnbmVkIGxvbmcgbG9uZyB0byBiZSA4DQo+ID4+Pj4gYnl0ZXMgb24gMzIg
Yml0LiBEbyB5b3UgcXVlc3Rpb24gdGhhdD8NCj4gPj4+DQo+ID4+PiBZZXMuDQo+ID4+Pg0KPiA+
Pj4gVGhlIGxpbnV4IEFCSSBmb3IgeDg2ICgzMiBiaXQpIG9ubHkgcmVxdWlyZXMgMzJiaXQgYWxp
Z25tZW50IGZvciB1NjQgKGV0YykuDQo+ID4+DQo+ID4+IEhtbSwgdTY0IG9uIDMyIGJpdCBpcyB1
bnNpZ25lZCBsb25nIGxvbmcgYW5kIG5vdCB1bnNpZ25lZCBsb25nLiBUaHVzIEkNCj4gPj4gYW0g
YWN0dWFsbHkgbm90IHN1cmUgaWYgdGhlIEFCSSB3b3VsZCBzYXkgYW55dGhpbmcgYWJvdXQgdGhh
dCAoc29ycnkNCj4gPj4gYWxzbyBmb3IgbXkgd3Jvbmcgc3RhdGVtZW50IGFib3ZlKS4NCj4gPj4N
Cj4gPj4gQWxpZ25tZW50IHJlcXVpcmVtZW50IG9mIHVuc2lnbmVkIGxvbmcgbG9uZyBvbiBnY2Mg
d2l0aCAtbTMyIGFjdHVhbGx5DQo+ID4+IHNlZW0gdG8gYmUgOC4NCj4gPg0KPiA+IEl0IGRlcGVu
ZHMgb24gdGhlIGFyY2hpdGVjdHVyZS4NCj4gPiBGb3IgeDg2IGl0IGlzIGRlZmluaXRlbHkgNC4N
Cj4gDQo+IE1heSBJIGFzayBmb3IgYSByZWZlcmVuY2U/DQoNCkFzayBhbnlvbmUgd2hvIGhhcyBo
YWQgdG8gZG8gY29tcGF0aWJpbGl0eSBsYXllcnMgdG8gc3VwcG9ydCAzMmJpdA0KYmluYXJpZXMg
b24gNjRiaXQgc3lzdGVtcy4NCg0KPiBJIGNvdWxkbid0IHNlZSB1bnNpZ25lZCBsb25nIGxvbmcg
YmVpbmcNCj4gbWVudGlvbmVkIGluIHRoZSBpYTMyIGFiaSBzcGVjIHRoYXQgSSBmb3VuZC4gSSBh
Z3JlZSB0aGF0IHRob3NlIGFjY2Vzc2VzDQo+IG1pZ2h0IGJlIHN5bnRoZXRpY2FsbHkgYXNzZW1i
bGVkIGJ5IGdjYyBhbmQgZm9yIG1lIHRoZSBhbGlnbm1lbnQgb2YgNA0KPiB3b3VsZCBoYXZlIHNl
ZW1lZCBuYXR1cmFsLiBCdXQgbXkgZ2NjIGF0IGxlYXN0IGluIDMyIGJpdCBtb2RlIGRpc2FncmVl
cw0KPiB3aXRoIHRoYXQuDQoNClRyeSAocmV0eXBlZCk6DQoNCmVjaG8gJ3N0cnVjdCB7IGxvbmcg
YTsgbG9uZyBsb25nIGI7IH0gczsgaW50IGJhciB7IHJldHVybiBzaXplb2YgczsgfScgPmZvby5j
DQpnY2MgWy1tMzJdIC1PMiAtUyBmb28uYzsgY2F0IGZvby5zDQoNCkFuZCBsb29rIGF0IHdoYXQg
aXMgZ2VuZXJhdGVkLg0KDQo+IFJpZ2h0IG5vdyBpcHY2IGFkZHJlc3NlcyBoYXZlIGFuIGFsaWdu
bWVudCBvZiA0LiBTbyB3ZSBjb3VsZG4ndCBldmVuDQo+IG5hdHVyYWxseSBwYXNzIHRoZW0gdG8g
c2lwaGFzaCBidXQgd291bGQgbmVlZCB0byBjb3B5IHRoZW0gYXJvdW5kLCB3aGljaA0KPiBJIGZl
ZWwgbGlrZSBhIHNvdXJjZSBvZiBidWdzLg0KDQpUaGF0IGlzIG1vcmUgb2YgYSBwcm9ibGVtIG9u
IHN5c3RlbXMgdGhhdCBkb24ndCBzdXBwb3J0IG1pc2FsaWduZWQgYWNjZXNzZXMuDQpSZWFkaW5n
IHRoZSA2NGJpdCB2YWx1ZXMgd2l0aCB0d28gZXhwbGljaXQgMzJiaXQgcmVhZHMgd291bGQgd29y
ay4NCkkgdGhpbmsgeW91IGNhbiBnZXQgZ2NjIHRvIGRvIHRoYXQgYnkgYWRkaW5nIGFuIGFsaWdu
ZWQoNCkgYXR0cmlidXRlIHRvIHRoZQ0Kc3RydWN0dXJlIG1lbWJlci4NCg0KCURhdmlkDQoNCg==
