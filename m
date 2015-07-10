From: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Subject: Re: [RFC net-next 03/22] ipv4: support for fib route
 lwtunnel encap attributes
Date: Fri, 10 Jul 2015 18:54:36 +0200
Message-ID: <20150710165436.GC11654@pox.localdomain>
References: <cover.1436537414.git.tgraf@suug.ch>
 <8ebc9066754f07003d54c3ac64d8c46f9c1c570b.1436537414.git.tgraf@suug.ch>
 <1436542616.24939.52.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, marcelo.leitner-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org,
 daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org, tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org, roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org,
 edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org,
 rshearma-43mecJUBy8ZBDgjK7y7TUQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1436542616.24939.52.camel-XN9IlZ5yJG9HTL0Zs8A6p/gx64E7kk8eUsxypvmhUTTZJqsBc5GL+g@public.gmane.org>
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

T24gMDcvMTAvMTUgYXQgMDU6MzZwbSwgRXJpYyBEdW1hemV0IHdyb3RlOgo+IE9uIEZyaSwgMjAx
NS0wNy0xMCBhdCAxNjoxOSArMDIwMCwgVGhvbWFzIEdyYWYgd3JvdGU6Cj4gPiBGcm9tOiBSb29w
YSBQcmFiaHUgPHJvb3BhQGN1bXVsdXNuZXR3b3Jrcy5jb20+Cj4gCj4gCj4gPiArCWlmIChvaWYp
Cj4gPiArCQlkZXYgPSBfX2Rldl9nZXRfYnlfaW5kZXgobmV0LCBvaWYpOwo+ID4gKwlyZXQgPSBs
d3R1bm5lbF9idWlsZF9zdGF0ZShkZXYsIGVuY2FwX3R5cGUsCj4gPiArCQkJCSAgIGVuY2FwLCAm
bHd0c3RhdGUpOwo+ID4gKwlpZiAoIXJldCkgewo+ID4gKwkJbHd0dW5uZWxfc3RhdGVfZ2V0KGx3
dHN0YXRlKTsKPiA+ICsJCXJldCA9IGx3dHVubmVsX2NtcF9lbmNhcChsd3RzdGF0ZSwgbmgtPm5o
X2x3dHN0YXRlKTsKPiA+ICsJCWx3dHVubmVsX3N0YXRlX3B1dChsd3RzdGF0ZSk7Cj4gPiArCj4g
PiArCQlyZXR1cm4gcmV0Owo+IAo+IAo+IFRoZXNlIF9nZXQoKS9fcHV0KCkgY2FsbHMgZG8gbm90
IHNlZW0gbmVjZXNzYXJ5LCBvciBidWdneS4KPiAKPiBJZiByZWZjb3VudGluZyBpcyBuZWVkZWQg
dGhlIF9nZXQoKSBzaG91bGQgYmUgZG9uZSBhdCB0aGUgdGltZSBsd3N0YXRlCj4gaXMgZmV0Y2hl
ZC4KCkknbGwgbGV0IFJvb3BhIGNvbW1lbnQgYnV0IGl0IHNlZW1zIGxpa2UgdGhlc2UgY2FuIGp1
c3QgYmUgcmVtb3ZlZC4KX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX18KZGV2IG1haWxpbmcgbGlzdApkZXZAb3BlbnZzd2l0Y2gub3JnCmh0dHA6Ly9vcGVudnN3
aXRjaC5vcmcvbWFpbG1hbi9saXN0aW5mby9kZXYK
