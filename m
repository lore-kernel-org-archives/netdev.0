From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Open vSwitch Design
Date: Fri, 25 Nov 2011 07:36:53 +0100
Message-ID: <1322203013.2872.28.camel@edumazet-laptop>
References: <1322173833.1944.5.camel@mojatatu>
	<20111124212021.2ae2fb7f@s6510.linuxnetplumber.net>
	<1322201883.2872.19.camel@edumazet-laptop>
	<20111125.012517.2221372383643417980.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, chrisw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Florian Westphal <fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org, jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org,
	john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, herbert-F6s6mLieUQo7FNHlEwC/lvQIK84fMopw@public.gmane.org,
	shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20111125.012517.2221372383643417980.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

TGUgdmVuZHJlZGkgMjUgbm92ZW1icmUgMjAxMSDDoCAwMToyNSAtMDUwMCwgRGF2aWQgTWlsbGVy
IGEgw6ljcml0IDoKPiBGcm9tOiBFcmljIER1bWF6ZXQgPGVyaWMuZHVtYXpldEBnbWFpbC5jb20+
Cj4gRGF0ZTogRnJpLCAyNSBOb3YgMjAxMSAwNzoxODowMyArMDEwMAo+IAo+ID4gTGUgamV1ZGkg
MjQgbm92ZW1icmUgMjAxMSDDoCAyMToyMCAtMDgwMCwgU3RlcGhlbiBIZW1taW5nZXIgYSDDqWNy
aXQgOgo+ID4gCj4gPj4gVGhlIHByb2JsZW0gaXMgdGhhdCB0aGVyZSBhcmUgdHdvIGZsb3cgY2xh
c3NpZmllcnMsIG9uZSBpbiBPcGVuVnN3aXRjaAo+ID4+IGluIHRoZSBrZXJuZWwsIGFuZCB0aGUg
b3RoZXIgaW4gdGhlIHVzZXIgc3BhY2UgZmxvdyBtYW5hZ2VyLiBJIHRoaW5rIHRoZQo+ID4+IGlz
c3VlIGlzIHRoYXQgdGhlIHR3byBoYXZlIGRpZmZlcmVudCBjb2RlLgo+ID4gCj4gPiBXZSBoYXZl
IGtpbmQgb2Ygc2FtZSBkdXBsaWNhdGlvbiBpbiBrZXJuZWwgYWxyZWFkeSA6KQo+ID4gCj4gPiBf
X3NrYl9nZXRfcnhoYXNoKCkgYW5kIG5ldC9zY2hlZC9jbHNfZmxvdy5jIGNvbnRhaW4gcm91Z2hs
eSB0aGUgc2FtZQo+ID4gbG9naWMuLi4KPiA+IAo+ID4gTWF5YmUgaXRzIHRpbWUgdG8gZmFjdG9y
aXplIHRoZSB0aGluZywgZXZlbnR1YWxseSB1c2UgaXQgaW4gYSB0aGlyZAo+ID4gY29tcG9uZW50
IChPcGVuIHZTd2l0Y2guLi4pCj4gCj4gWWVzLgoKQSB0aGlyZCByZWFzb24gdG8gZG8gdGhhdCBh
bnl3YXkgaXMgdGhhdCBuZXQvc2NoZWQvc2NoX3NmYi5jIHNob3VsZCB1c2UKX19za2JfZ2V0X3J4
aGFzaCgpIHByb3ZpZGluZyB0aGUgcGVydHVyYmF0aW9uIGl0c2VsZiwgYW5kIG5vdCB1c2UgdGhl
CnN0YW5kYXJkIChoYXNocm5kKSBvbmUgKS4KClJpZ2h0IG5vdywgaWYgdHdvIGZsb3dzIHNoYXJl
IHNhbWUgcnhoYXNoLCB0aGUgZG91YmxlIFNGQiBoYXNoIHdpbGwgYWxzbwpzaGFyZSB0aGUgc2Ft
ZSBmaW5hbCBoYXNoLgoKKFRoaXMgcG9pbnQgd2FzIG1lbnRpb25lZCBieSBGbG9yaWFuIFdlc3Rw
aGFsKQoKCgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpk
ZXYgbWFpbGluZyBsaXN0CmRldkBvcGVudnN3aXRjaC5vcmcKaHR0cDovL29wZW52c3dpdGNoLm9y
Zy9tYWlsbWFuL2xpc3RpbmZvL2Rldgo=
