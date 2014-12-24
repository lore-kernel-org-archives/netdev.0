From: kbuild test robot <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] openvswitch: fix odd_ptr_err.cocci warnings
Date: Wed, 24 Dec 2014 14:41:39 +0800
Message-ID: <20141224064138.GA11360@athens>
References: <201412241437.BpaCtsIE%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kbuild-all-JC7UmRfGjtg@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <201412241437.BpaCtsIE%fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

bmV0L29wZW52c3dpdGNoL3Zwb3J0LWdyZS5jOjE4ODo1LTExOiBpbmNvbnNpc3RlbnQgSVNfRVJS
IGFuZCBQVFJfRVJSLCBQVFJfRVJSIG9uIGxpbmUgMTg5CgogUFRSX0VSUiBzaG91bGQgYWNjZXNz
IHRoZSB2YWx1ZSBqdXN0IHRlc3RlZCBieSBJU19FUlIKClNlbWFudGljIHBhdGNoIGluZm9ybWF0
aW9uOgogVGhlcmUgY2FuIGJlIGZhbHNlIHBvc2l0aXZlcyBpbiB0aGUgcGF0Y2ggY2FzZSwgd2hl
cmUgaXQgaXMgdGhlIGNhbGwKIElTX0VSUiB0aGF0IGlzIHdyb25nLgoKR2VuZXJhdGVkIGJ5OiBz
Y3JpcHRzL2NvY2NpbmVsbGUvdGVzdHMvb2RkX3B0cl9lcnIuY29jY2kKCkNDOiBQcmF2aW4gQiBT
aGVsYXIgPHBzaGVsYXJAbmljaXJhLmNvbT4KU2lnbmVkLW9mZi1ieTogRmVuZ2d1YW5nIFd1IDxm
ZW5nZ3Vhbmcud3VAaW50ZWwuY29tPgotLS0KCiB2cG9ydC1ncmUuYyB8ICAgIDIgKy0KIDEgZmls
ZSBjaGFuZ2VkLCAxIGluc2VydGlvbigrKSwgMSBkZWxldGlvbigtKQoKLS0tIGEvbmV0L29wZW52
c3dpdGNoL3Zwb3J0LWdyZS5jCisrKyBiL25ldC9vcGVudnN3aXRjaC92cG9ydC1ncmUuYwpAQCAt
MTg2LDcgKzE4Niw3IEBAIHN0YXRpYyBpbnQgZ3JlX3RubF9zZW5kKHN0cnVjdCB2cG9ydCAqdnAK
IAkvKiBQdXNoIFR1bm5lbCBoZWFkZXIuICovCiAJc2tiID0gX19idWlsZF9oZWFkZXIoc2tiLCB0
dW5uZWxfaGxlbik7CiAJaWYgKElTX0VSUihza2IpKSB7Ci0JCWVyciA9IFBUUl9FUlIocnQpOwor
CQllcnIgPSBQVFJfRVJSKHNrYik7CiAJCXNrYiA9IE5VTEw7CiAJCWdvdG8gZXJyX2ZyZWVfcnQ7
CiAJfQpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpkZXYg
bWFpbGluZyBsaXN0CmRldkBvcGVudnN3aXRjaC5vcmcKaHR0cDovL29wZW52c3dpdGNoLm9yZy9t
YWlsbWFuL2xpc3RpbmZvL2Rldgo=
