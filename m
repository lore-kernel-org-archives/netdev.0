From: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Subject: RE: [PATCH RFC 1/1] usb: Tell xhci when usb data might be misaligned
Date: Mon, 3 Feb 2014 09:54:09 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6B7707@AcuExch.aculab.com>
References: <20140130211816.GB3787@xanatos>	<87iot1qgv6.fsf@nemi.mork.no>
	<20140130221511.GD14228@xanatos>
	<CACVXFVMVoMAH3DRiv-VYZL8VWq2Rw+fZwreVtUVm1M44HR+X8Q@mail.gmail.com>
	<20140131190035.GB18262@xanatos>
	<CACVXFVN3OsPM5CBWjc4kh_sGo3fMwpvBoYer7VtreUWrvWA=+Q@mail.gmail.com>
	<52ECF6F5.6060207@pobox.com>
 <CACVXFVOynsojKo+aukHY4q+MkEyhHXC0=OpN0ysu0TGuUjY8sA@mail.gmail.com>
 <52ED5381.2010106@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Sarah Sharp <sarah.a.sharp-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	=?utf-8?B?QmrDuHJuIE1vcms=?= <bjorn-yOkvZcmFvRU@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Dan Williams" <dan.j.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Nyman, Mathias" <mathias.nyman-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	Freddy Xin <freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>
To: 'Mark Lord' <mlord-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <52ED5381.2010106-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Content-Language: en-US
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

RnJvbTogTWFyayBMb3JkDQo+IE9uIDE0LTAyLTAxIDA5OjE4IEFNLCBNaW5nIExlaSB3cm90ZToN
Cj4gPg0KPiA+IEV2ZW4gcmVhbCByZWdyZXNzaW9ucyBhcmUgZWFzaWx5L29mdGVuIGludHJvZHVj
ZWQsIGFuZCB3ZSBhcmUgZGlzY3Vzc2luZw0KPiA+IGhvdyB0byBmaXggdGhhdC4gSSBzdWdnZXN0
IHRvIHVuc2V0IHRoZSBmbGFnIG9ubHkgZm9yIHRoZSBrbm93biBidWdneQ0KPiA+IGNvbnRyb2xs
ZXJzLg0KPiANCj4gSXQgaXMgbm90IHRoZSBjb250cm9sbGVycyB0aGF0IGFyZSBwYXJ0aWN1bGFy
bHkgImJ1Z2d5IiBoZXJlLg0KPiBCdXQgcmF0aGVyIHRoZSBkcml2ZXJzIGFuZCBkZXNpZ24gb2Yg
cGFydHMgb2YgdGhlIGtlcm5lbC4NCg0KSSBzdXNwZWN0IHRoYXQgdGhlIGRvY3VtZW50YXRpb24g
aXMgZGVzY3JpYmluZyB0aGUgYWN0dWFsIGltcGxlbWVudGF0aW9uDQpvZiBhIHNwZWNpZmljIGhh
cmR3YXJlIGltcGxlbWVudGF0aW9uLCBub3QgbmVjZXNzYXJpbHkgaG93IHRoZSBoYXJkd2FyZSB3
YXMNCmludGVuZGVkIHRvIGJlaGF2ZS4NCg0KVGhlIHJlcXVpcmVtZW50IGZvciB0d28gMzJiaXQg
YWNjZXNzZXMgdG8gYSA2NGJpdCByZWdpc3RlciBpcyB2ZXJ5IHNpbWlsYXIuDQoNClRoaXMgYWxz
byBtZWFucyB0aGF0IGltcGxlbWVudGF0aW9ucyBvZiB0aGUgaGFyZHdhcmUgdGhhdCBjbGFpbSBj
b25mb3JtYW5jZQ0KdG8gdGhlIDAuOTYgc3BlY2lmaWNhdGlvbiBtaWdodCBoYXZlIHNpbWlsYXIg
aXNzdWVzLg0KDQpHaXZlbiB0aGUgc21hbGwgbnVtYmVyIG9mIHhoY2kgY29udHJvbGxlcnMgYW5k
IHRoZSBldmVuIHNtYWxsZXIgbnVtYmVyIG9mDQpWSERMIChvciBzaW1pbGFyKSBzb3VyY2VzIHRo
ZXkgd2lsbCBiZSBiYXNlZCBvbiwgaXQgcmVhbGx5IG91Z2h0IHRvIGJlDQpwb3NzaWJsZSB0byB0
YWJ1bGF0ZSB0aGUgY29udHJvbGxlciB2ZXJzaW9ucyBhbmQgZmFtaWxpZXMgdG8gZ2V0IGEgbXVj
aA0KYmV0dGVyIGlkZWEgb2YgdGhlaXIgYmVoYXZpb3VyLg0KDQpJJ3ZlIGdvdCB0d28gc3lzdGVt
cyB3aXRoIEludGVsIFVTQjMgY29udHJvbGxlcnMsIGxpbnV4IHJlcG9ydHMgb25lIGFzDQoncGFu
dGhlciBwb2ludCcsIHRoZSBvdGhlciBhcyAnNyBTZXJpZXMvQzIxMCBTZXJpZXMnIChzZWVtcyB0
byBiZSBhIFhlb24NCmNoaXBzZXQpLiBJJ3ZlIG5vIGlkZWEgaG93IHRoZSBsYXR0ZXIgcmVsYXRl
cyB0byB0aGUgZm9ybWVyLg0KDQoJRGF2aWQNCg0K
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
