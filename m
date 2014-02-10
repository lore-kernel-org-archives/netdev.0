From: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Subject: RE: [PATCH 1/2 v2] usbnet: fix bad header length bug
Date: Mon, 10 Feb 2014 12:39:07 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6BBDD0@AcuExch.aculab.com>
References: <1391987174-21828-1-git-send-email-emilgoode@gmail.com>
	 <1392014458.21271.6.camel@linux-fkkt.site> <20140210115812.GA4278@lianli>
 <1392034947.2082.30.camel@linux-fkkt.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	Mark Brown <broonie-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Glen Turner <gdt-pRLresKaOUyHXe+LvDLADg@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: 'Oliver Neukum' <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>,
	Emil Goode <emilgoode-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1392034947.2082.30.camel-B2T3B9s34ElbnMAlSieJcQ@public.gmane.org>
Content-Language: en-US
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

RnJvbTogT2xpdmVyIE5ldWt1bQ0KPiA8Y2Vuc29yZWQ+LiBPaCB3ZWxsLiBCdXQgaG93IGFib3V0
IG1lcmdpbmcgaXQgd2l0aCBGTEFHX01VTFRJX1BBQ0tFVD8NCj4gSSByZWFsbHkgZG9uJ3Qgd2Fu
dCB0byBhZGQgbW9yZSBmbGFncy4gVGhlcmUgaXMgYSBwb2ludCB3aGVyZSBlbm91Z2gNCj4gZmxh
Z3MgbWFrZSBhYnN1cmQgaGF2aW5nIGEgY29tbW9uIGNvZGUuIFdlIGFyZSBjbG9zaW5nIGluIG9u
IHRoYXQgcG9pbnQuDQoNCkFueSBzdWItZHJpdmVyIHRoYXQgc3VwcG9ydHMgbXVsdGktcGFja2V0
IGVpdGhlciBoYXMgdG8gdXNlIHN0dXBpZGx5DQpsb25nIFVSQiBhbmQvb3Igc2V0IHRoZSByeF91
cmJfc2l6ZSB0byBhIG11bHRpcGxlIG9mIHRoZSB1c2IgdHJhbnNmZXINCnNpemUuDQoNCkl0IHdp
bGwgYWxzbyBoYXZlIHRvIGRldGVjdCBpbGxlZ2FsIHNob3J0IGhlYWRlcnMuDQoNCkFjdHVhbGx5
IGl0IG1pZ2h0IGJlIHdvcnRoIGRvdWJsZS1jaGVja2luZyB0aGUgZW5jYXBzdWxhdGlvbnMgdXNl
ZC4NCklJUkMgdGhlIGF4ODgxNzlfMTc4YSB1c2VzIGRpZmZlcmVudCBoZWFkZXJzIGZvciB0eCBh
bmQgcnguDQpTbyB0aGVyZSBtaWdodCBiZSBzb21lIHRoYXQgc3VwcG9ydCBtdWx0aS1wYWNrZXQg
YnV0IHN0aWxsIGhhdmUNCmEgc2hvcnQoaXNoKSBsaW1pdCBvbiB0aGUgYnVsayByZWNlaXZlIHNp
emUgKGJlZm9yZSB0aGUgc2hvcnQgZnJhZ21lbnQpLg0KDQpJJ20gc2F0IGF0IHRoZSB3cm9uZyBk
ZXNrIHRvIGxvb2sgYXQgdGhlIGNvZGUuLi4NCg0KCURhdmlkDQoNCg==
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
