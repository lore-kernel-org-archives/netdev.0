From: "David Laight" <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Subject: RE: [PATCH] usb: xhci: Link TRB must not occur with a USB payload burst.
Date: Wed, 20 Nov 2013 15:54:27 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B743A@saturn3.aculab.com>
References: <20131119225822.GA9611@xanatos> <Pine.LNX.4.44L0.1311192204140.6891-100000@netrider.rowland.org> <AE90C24D6B3A694183C094C60CF0A2F6026B7437@saturn3.aculab.com> <1384959827.8604.141.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "Alan Stern" <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	"Sarah Sharp" <sarah.a.sharp-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	"Ben Hutchings" <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Eric Dumazet" <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-class: urn:content-classes:message
In-Reply-To: <1384959827.8604.141.camel-XN9IlZ5yJG9HTL0Zs8A6p/gx64E7kk8eUsxypvmhUTTZJqsBc5GL+g@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

PiBGcm9tOiBFcmljIER1bWF6ZXQgW21haWx0bzplcmljLmR1bWF6ZXRAZ21haWwuY29tXQ0KPiBP
biBXZWQsIDIwMTMtMTEtMjAgYXQgMDk6MzYgKzAwMDAsIERhdmlkIExhaWdodCB3cm90ZToNCj4g
DQo+ID4gQmVuIHNhaWQgdGhlIGxhcmdlc3QgbnVtYmVyIG9mIGZyYWdtZW50cyBmcm9tIHRoZSBj
dXJyZW50IG5ldHdvcmsNCj4gPiBzdGFjayB3aWxsIGJlIDE3LCBhbmQgdGhhdCBub25lIG9mIHRo
ZW0gd2lsbCBjcm9zcyAzMmsgYm91bmRhcmllcy4NCj4gPiBTbyB0aGUgbmV0d29yayBzdGFjayB3
b24ndCBzZW5kIGRvd24gbG9uZyBTRyBsaXN0cy4NCj4gDQo+IFBsZWFzZSBub3RlIHRoYXQgc2ti
LT5oZWFkIGl0c2VsZiBfbWlnaHRfIGNyb3NzIGEgMzJLIG9yIDY0SyBib3VuZGFyeSA6DQo+IA0K
PiBza2ItPmhlYWQgaXMga21hbGxvYygpIHByb3ZpZGVkLCBhbmQgU0xVQiBjYW4gYmUgdHdlYWtl
ZA0KPiAoc2x1Yl9tYXhfb3JkZXIpIHRvIHVzZSB2ZXJ5IGhpZ2ggb3JkZXIgcGFnZXMuDQoNCldv
cnRoIHJlbWVtYmVyaW5nLi4uDQoNCkkgc3VzcGVjdCB0aGUgbnVtYmVyIG9mIGZyYWdtZW50cyAo
aW5jIDY0ayBib3VuZGFyaWVzKSBpcyBzdGlsbCBsaW1pdGVkDQpiZWNhdXNlIG1heGltdW0gZGF0
YSBsZW5ndGggaXMgdW5kZXIgNjRrIChmb3IgVFNPKSBhbmQgdGhlIFNMVUIgbWVtb3J5DQpoYXMg
dG8gYmUgcGh5c2ljYWxseSBjb250aWd1b3VzIChpdCBpcyBzdGlsbCBsaW1pdGVkIGV2ZW4gaWYg
bm90KS4NCg0KQXQgdGhlIG1vbWVudCB0aGUgdXNiIGJ1bGsgdHggY29kZSBjYWxjdWxhdGVkIHRo
ZSBleGFjdCBudW1iZXIgb2YNCmZyYWdtZW50cyBuZWVkZWQuIFRvIGRvIHRoaXMgaXQgaGFzIHRv
IHNjYW4gdGhlIHNnIGxpc3QgdHdpY2UuDQpJdCB3b3VsZCBzZWVtIG1vcmUgc2Vuc2libGUgdG8g
Z2VuZXJhdGUgYSBxdWljayB1cHBlciBib3VuZA0KKGllIG5mcmFncyoyICsgbGVuLzY1NTM2KSBh
bmQgbWF5YmUgY2FsY3VsYXRlIHRoZSBleGFjdCBudW1iZXINCmlmIHRoaXMgd291bGQgZXhjZWVk
IHRoZSBtYXhpbXVtIG51bWJlci4NCk9UT0ggdGhlIG1heCBhbGxvd2VkIGNvdWxkIGJlIGRvY3Vt
ZW50ZWQgdGhhdCB3YXkuDQoNCkluIGFueSBjYXNlIHRoaXMgaXMgYWxsIGFzaWRlIGZyb20gdGhl
IGJ1ZyBpdHNlbGYuDQoNCglEYXZpZA0K
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
