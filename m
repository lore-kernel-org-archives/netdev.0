From: Simon Horman <simon.horman-wFxRvT7yatFl57MIdRCFDg@public.gmane.org>
Subject: Re: [PATCH v9 net-next 4/7] openvswitch: add layer 3
 flow/port support
Date: Fri, 20 May 2016 17:11:23 +0900
Message-ID: <20160520081120.GA17561@vergenet.net>
References: <1462347393-22354-1-git-send-email-simon.horman@netronome.com>
 <1462347393-22354-5-git-send-email-simon.horman@netronome.com>
 <20160517163250.7ead555e@griffin>
 <20160520052858.GA15505@vergenet.net>
 <20160520100028.0065a2ef@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160520100028.0065a2ef@griffin>
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

T24gRnJpLCBNYXkgMjAsIDIwMTYgYXQgMTA6MDA6MjhBTSArMDIwMCwgSmlyaSBCZW5jIHdyb3Rl
Ogo+IE9uIEZyaSwgMjAgTWF5IDIwMTYgMTQ6Mjk6MDEgKzA5MDAsIFNpbW9uIEhvcm1hbiB3cm90
ZToKPiA+IFRoZSBzZWNvbmQgb3B0aW9uIGRvZXMgc2VlbSByYXRoZXIgdGVtcHRpbmcgYWx0aG91
Z2ggSSdtIG5vdCBzdXJlCj4gPiB0aGF0IGl0IGFjdHVhbGx5IHBsYXlzIG91dCBpbiB0aGUgYWNj
ZXNzLXBvcnQgc2NlbmFyaW8gYXQgdGhpcyB0aW1lLgo+IAo+IFdlIHN1cHBvcnQgZ3JlIHBvcnRz
IHRvIGJlIGFjY2VzcyBwb3J0cyBjdXJyZW50bHkuIFdpdGggY29udmVyc2lvbiB0bwo+IGlwZ3Jl
LCB0aGlzIG5lZWRzIHRvIGNvbnRpbnVlIHdvcmtpbmcuIEl0J3Mgbm8gcHJvYmxlbSBmb3IgZnJh
bWVzIHdpdGgKPiB0aGUgRXRoZXJuZXQgaGVhZGVyIGJ1dCBub3cgd2UgaGF2ZSBhIHNpdHVhdGlv
biB3aGVyZSBhIHBvcnQgaXMgdGFnZ2VkLAo+IHRodXMgdGhlIHVzZXIgZXhwZWN0cyB0aGF0IHBh
Y2tldHMgcmVjZWl2ZWQgb24gdGhhdCBwb3J0IHdpbGwgYmVoYXZlCj4gYWNjb3JkaW5nbHkuIEkg
ZG9uJ3QgdGhpbmsgd2UgY2FuIG1ha2Ugc29tZSBwYWNrZXRzIGhvbm9yIHRoaXMgYW5kIHNvbWUK
PiBpZ25vcmUgdGhpczsgYW5kIHdlIGNhbid0IGRpc2FsbG93IGdyZSB0byBiZSBhbiBhY2Nlc3Mg
cG9ydC4KPiAKPiBIb3cgZG8geW91IHBsYW4gdG8gc29sdmUgdGhpcz8gQnkgdXNlciBzcGFjZSBh
bHdheXMgcHVzaGluZyBhbiBldGhlcm5ldAo+IGhlYWRlciBiZWZvcmUgcHVzaF92bGFuPwoKWWVz
LiBUaGF0IGlzIG15IHVuZGVyc3RhbmRpbmcgb2YgaG93IE92UyBjdXJyZW50bHkgaGFuZGxlcyBh
Y2Nlc3MgcG9ydHMgYnV0CkkgaGF2ZSBhIGZlZWxpbmcgdGhhdCBlaXRoZXIgSSBhbSBtaXN0YWtl
biBvciB0aGF0IHlvdSBhcmUgcmVmZXJyaW5nIHRvIGEKc2xpZ2h0bHkgZGlmZmVyZW50IHNjZW5h
cmlvLgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpkZXYg
bWFpbGluZyBsaXN0CmRldkBvcGVudnN3aXRjaC5vcmcKaHR0cDovL29wZW52c3dpdGNoLm9yZy9t
YWlsbWFuL2xpc3RpbmZvL2Rldgo=
