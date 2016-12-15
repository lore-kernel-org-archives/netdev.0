From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2 1/4] siphash: add cryptographically secure hashtable
 function
Date: Thu, 15 Dec 2016 11:04:37 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB02401ED@AcuExch.aculab.com>
References: <20161214035927.30004-1-Jason@zx2c4.com>
 <CAHmME9q9ffdtWRbzyMO1ktTdtEFdfumTfojTTNLXFhoa+R+MWQ@mail.gmail.com>
 <8ea3fdff-23c4-b81d-2588-44549bd2d8c1@stressinduktion.org>
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
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <8ea3fdff-23c4-b81d-2588-44549bd2d8c1@stressinduktion.org>
Content-Language: en-US
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RnJvbTogSGFubmVzIEZyZWRlcmljIFNvd2ENCj4gU2VudDogMTQgRGVjZW1iZXIgMjAxNiAyMjow
Mw0KPiBPbiAxNC4xMi4yMDE2IDEzOjQ2LCBKYXNvbiBBLiBEb25lbmZlbGQgd3JvdGU6DQo+ID4g
SGkgRGF2aWQsDQo+ID4NCj4gPiBPbiBXZWQsIERlYyAxNCwgMjAxNiBhdCAxMDo1NiBBTSwgRGF2
aWQgTGFpZ2h0IDxEYXZpZC5MYWlnaHRAYWN1bGFiLmNvbT4gd3JvdGU6DQo+ID4+IC4uLg0KPiA+
Pj4gK3U2NCBzaXBoYXNoMjQoY29uc3QgdTggKmRhdGEsIHNpemVfdCBsZW4sIGNvbnN0IHU4IGtl
eVtTSVBIQVNIMjRfS0VZX0xFTl0pDQo+ID4+IC4uLg0KPiA+Pj4gKyAgICAgdTY0IGswID0gZ2V0
X3VuYWxpZ25lZF9sZTY0KGtleSk7DQo+ID4+PiArICAgICB1NjQgazEgPSBnZXRfdW5hbGlnbmVk
X2xlNjQoa2V5ICsgc2l6ZW9mKHU2NCkpOw0KPiA+PiAuLi4NCj4gPj4+ICsgICAgICAgICAgICAg
bSA9IGdldF91bmFsaWduZWRfbGU2NChkYXRhKTsNCj4gPj4NCj4gPj4gQWxsIHRoZXNlIHVuYWxp
Z25lZCBhY2Nlc3NlcyBhcmUgZ29pbmcgdG8gZ2V0IGV4cGVuc2l2ZSBvbiBhcmNoaXRlY3R1cmVz
DQo+ID4+IGxpa2Ugc3BhcmM2NC4NCj4gPg0KPiA+IFllcywgdGhlIHVuYWxpZ25lZCBhY2Nlc3Nl
cyBhcmVuJ3QgcHJldHR5LiBTaW5jZSBpbiBwcmV0dHkgbXVjaCBhbGwNCj4gPiB1c2UgY2FzZXMg
dGh1cyBmYXIsIHRoZSBkYXRhIGNhbiBlYXNpbHkgYmUgbWFkZSBhbGlnbmVkLCBwZXJoYXBzIGl0
DQo+ID4gbWFrZXMgc2Vuc2UgdG8gY3JlYXRlIHNpcGhhc2gyNCgpIGFuZCBzaXBoYXNoMjRfdW5h
bGlnbmVkKCkuIEFueQ0KPiA+IHRob3VnaHRzIG9uIGRvaW5nIHNvbWV0aGluZyBsaWtlIHRoYXQ/
DQo+IA0KPiBJIGZlYXIgdGhhdCB0aGUgYWxpZ25tZW50IHJlcXVpcmVtZW50IHdpbGwgYmUgYSBz
b3VyY2Ugb2YgYnVncyBvbiAzMiBiaXQNCj4gbWFjaGluZXMsIHdoZXJlIHlvdSBjYW5ub3QgZXZl
biBzaW1wbHkgdGFrZSBhIHdlbGwgYWxpZ25lZCBzdHJ1Y3Qgb24gYQ0KPiBzdGFjayBhbmQgcHV0
IGl0IGludG8gdGhlIG5vcm1hbCBzaXBoYXNoKGFsaWduZWQpIGZ1bmN0aW9uIHdpdGhvdXQNCj4g
YWRkaW5nIGFsaWdubWVudCBhbm5vdGF0aW9ucyBldmVyeXdoZXJlLiBFdmVuIGJsb2NrcyByZXR1
cm5lZCBmcm9tDQo+IGttYWxsb2Mgb24gMzIgYml0IGFyZSBub3QgYWxpZ25lZCB0byA2NCBiaXQu
DQoNCkFyZSB5b3UgZG9pbmcgYW55dGhpbmcgdGhhdCB3aWxsIHJlcXVpcmUgNjRiaXQgYWxpZ25t
ZW50IG9uIDMyYml0IHN5c3RlbXM/DQpJdCBpcyB1bmxpa2VseSB0aGF0IHRoZSBrZXJuZWwgY2Fu
IHVzZSBhbnkgc2ltZCByZWdpc3RlcnMgdGhhdCBoYXZlIHdpZGVyDQphbGlnbm1lbnQgcmVxdWly
ZW1lbnRzLg0KDQpZb3UgYWxzbyByZWFsbHkgZG9uJ3Qgd2FudCB0byByZXF1ZXN0IG9uLXN0YWNr
IGl0ZW1zIGhhdmUgbGFyZ2UgYWxpZ25tZW50cy4NCldoaWxlIGdjYyBjYW4gZ2VuZXJhdGUgY29k
ZSB0byBkbyBpdCwgaXQgaXNuJ3QgcHJldHR5Lg0KDQoJRGF2aWQNCg0KDQo=
