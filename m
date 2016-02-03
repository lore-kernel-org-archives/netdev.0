From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2] unix: properly account for FDs passed over unix
 sockets
Date: Wed, 3 Feb 2016 12:19:11 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CCD516C@AcuExch.aculab.com>
References: <201601100657.u0A6vk1B025554@mail.home.local>
	<CANq1E4T0sqTTD4RsWXTUrFvsKvEsKsUiPbskWd=wAEVu83_Srg@mail.gmail.com>
	<56B0F574.5080105@stressinduktion.org>
	<CA+55aFw2AwsWbvwp6f8H+eExt_CMfh7VA3od6hto_M0hg9z3Tg@mail.gmail.com>
	<56B11278.8000805@stressinduktion.org>
 <CA+55aFz0CXGexEBmb8JU0+w7sFf3VfE3TpRzdj3aTiDxg2zDpg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: David Herrmann <dh.herrmann@gmail.com>, Willy Tarreau <w@1wt.eu>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	???? ????????? <socketpair@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Simon McVittie <simon.mcvittie@collabora.co.uk>
To: 'Linus Torvalds' <torvalds@linux-foundation.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFz0CXGexEBmb8JU0+w7sFf3VfE3TpRzdj3aTiDxg2zDpg@mail.gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RnJvbTogTGludXMgVG9ydmFsZHMNCj4gU2VudDogMDIgRmVicnVhcnkgMjAxNiAyMDo0NQ0KPiBP
biBUdWUsIEZlYiAyLCAyMDE2IGF0IDEyOjMyIFBNLCBIYW5uZXMgRnJlZGVyaWMgU293YQ0KPiA8
aGFubmVzQHN0cmVzc2luZHVrdGlvbi5vcmc+IHdyb3RlOg0KPiA+DQo+ID4gVW5mb3J0dW5hdGVs
eSB3ZSBuZXZlciB0cmFuc2ZlciBhIHNjbV9jb29raWUgdmlhIHRoZSBza2JzIGJ1dCBtZXJlbHkg
dXNlIGl0DQo+ID4gdG8gaW5pdGlhbGl6ZSB1bml4X3NrYl9wYXJtcyBzdHJ1Y3R1cmUgaW4gc2ti
LT5jYiBhbmQgZGVzdHJveSBpdCBhZnRlcndhcmRzLg0KPiANCj4gT2ssIEkgb2J2aW91c2x5IGRp
ZG4ndCBjaGVjayB2ZXJ5IGNsb3NlbHkuDQo+IA0KPiA+IEJ1dCAic3RydWN0IHBpZCAqIiBpbiB1
bml4X3NrYl9wYXJtcyBzaG91bGQgYmUgZW5vdWdoIHRvIGdldCB1cyB0bw0KPiA+IGNvcnJlc3Bv
bmRpbmcgInN0cnVjdCBjcmVkICoiIHNvIHdlIGNhbiBkZWNyZW1lbnQgdGhlIGNvcnJlY3QgY291
bnRlciBkdXJpbmcNCj4gPiBza2IgZGVzdHJ1Y3Rpb24uDQo+IA0KPiBVbW0uIEkgdGhpbmsgdGhl
ICJzdHJ1Y3QgY3JlZCIgbWF5IGNoYW5nZSBpbiBiZXR3ZWVuLCBjYW4ndCBpdD8NCj4gDQo+IFNv
IEkgZG9uJ3QgdGhpbmsgeW91IGNhbiBsYXRlciBsb29rIHVwIHRoZSBjcmVkIGJhc2VkIG9uIHRo
ZSBwaWQuDQo+IA0KPiBDb3VsZCB3ZSBhZGQgdGhlIGNyZWQgcG9pbnRlciAob3IganVzdCB0aGUg
dXNlciBwb2ludGVyKSB0byB0aGUgdW5peF9za2JfcGFybXM/DQo+IA0KPiBPciBtYXliZSBqdXN0
IGFkZCBpdCB0byB0aGUgInN0cnVjdCBzY21fZnBfbGlzdCI/DQoNCklzIHRoYXQgZ29pbmcgdG8g
d29yayBpZiB0aGUgc2VuZGluZyBwcm9jZXNzIGV4aXRzIGJlZm9yZSB0aGUgbWVzc2FnZSBpcyBy
ZWFkPw0KWW91IG5lZWQgYSByZWZlcmVuY2UgY291bnQgYWdhaW5zdCB0aGUgc3RydWN0dXJlIHRo
YW4gY29udGFpbnMgdGhlIGNvdW50Lg0KSSB0aGluayB0aGlzIGlzICdzdHJ1Y3QgdXNlcicgbm90
ICdzdHJ1Y3QgY3JlZCcNCg0KCURhdmlkDQoNCg==
