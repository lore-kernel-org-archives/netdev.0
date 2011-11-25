From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: Open vSwitch Design
Date: Fri, 25 Nov 2011 12:14:42 -0800
Message-ID: <CAEP_g=8zCdvP46DX4OWRyWoq9CJGOsUCbGTGo_ybRQFxs9W3Fw@mail.gmail.com>
References: <CAEP_g=_2L1xFWtDXh_6YyXz1Mt9TR3zvjLzix+SpO6yzeOLsSQ@mail.gmail.com>
	<1322173833.1944.5.camel@mojatatu>
	<20111124212021.2ae2fb7f@s6510.linuxnetplumber.net>
	<1322201883.2872.19.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, Chris Wright <chrisw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org,
	jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org, John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1322201883.2872.19.camel@edumazet-laptop>
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

T24gVGh1LCBOb3YgMjQsIDIwMTEgYXQgMTA6MTggUE0sIEVyaWMgRHVtYXpldCA8ZXJpYy5kdW1h
emV0QGdtYWlsLmNvbT4gd3JvdGU6Cj4gTGUgamV1ZGkgMjQgbm92ZW1icmUgMjAxMSDDoCAyMToy
MCAtMDgwMCwgU3RlcGhlbiBIZW1taW5nZXIgYSDDqWNyaXQgOgo+Cj4+IFRoZSBwcm9ibGVtIGlz
IHRoYXQgdGhlcmUgYXJlIHR3byBmbG93IGNsYXNzaWZpZXJzLCBvbmUgaW4gT3BlblZzd2l0Y2gK
Pj4gaW4gdGhlIGtlcm5lbCwgYW5kIHRoZSBvdGhlciBpbiB0aGUgdXNlciBzcGFjZSBmbG93IG1h
bmFnZXIuIEkgdGhpbmsgdGhlCj4+IGlzc3VlIGlzIHRoYXQgdGhlIHR3byBoYXZlIGRpZmZlcmVu
dCBjb2RlLgo+Cj4gV2UgaGF2ZSBraW5kIG9mIHNhbWUgZHVwbGljYXRpb24gaW4ga2VybmVsIGFs
cmVhZHkgOikKPgo+IF9fc2tiX2dldF9yeGhhc2goKSBhbmQgbmV0L3NjaGVkL2Nsc19mbG93LmMg
Y29udGFpbiByb3VnaGx5IHRoZSBzYW1lCj4gbG9naWMuLi4KPgo+IE1heWJlIGl0cyB0aW1lIHRv
IGZhY3Rvcml6ZSB0aGUgdGhpbmcsIGV2ZW50dWFsbHkgdXNlIGl0IGluIGEgdGhpcmQKPiBjb21w
b25lbnQgKE9wZW4gdlN3aXRjaC4uLikKCkkgYWdyZWUsIHRoZXJlJ3Mgbm8gbmVlZCB0byBoYXZl
IHRocmVlIGNvcGllcyBvZiBwYWNrZXQgaGVhZGVyIHBhcnNpbmcKY29kZSBhbmQgdGhhdCdzIGNl
cnRhaW5seSBzb21ldGhpbmcgdGhhdCB3ZSB3b3VsZCBiZSB3aWxsaW5nIHRvIHdvcmsKb24gaW1w
cm92aW5nLgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpk
ZXYgbWFpbGluZyBsaXN0CmRldkBvcGVudnN3aXRjaC5vcmcKaHR0cDovL29wZW52c3dpdGNoLm9y
Zy9tYWlsbWFuL2xpc3RpbmZvL2Rldgo=
