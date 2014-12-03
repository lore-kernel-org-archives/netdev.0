From: Joe Stringer <joestringer-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCHv11 net-next 1/2] openvswitch: Refactor
	ovs_nla_fill_match().
Date: Wed, 3 Dec 2014 13:42:38 -0800
Message-ID: <CANr6G5xWMYv2=z7TES+pYqHDqxFmrzP+RpXfUDC6qUL_yqkJEQ@mail.gmail.com>
References: <1417575363-13770-1-git-send-email-joestringer@nicira.com>
 <CALnjE+pNbwtGPsHfTJ0FXxdSpXT=AKgtfHPqT5matCx+PGcXbA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
 netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Pravin Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <CALnjE+pNbwtGPsHfTJ0FXxdSpXT=AKgtfHPqT5matCx+PGcXbA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

T24gMyBEZWNlbWJlciAyMDE0IGF0IDExOjM3LCBQcmF2aW4gU2hlbGFyIDxwc2hlbGFyQG5pY2ly
YS5jb20+IHdyb3RlOgo+IE9uIFR1ZSwgRGVjIDIsIDIwMTQgYXQgNjo1NiBQTSwgSm9lIFN0cmlu
Z2VyIDxqb2VzdHJpbmdlckBuaWNpcmEuY29tPiB3cm90ZToKPj4gZGlmZiAtLWdpdCBhL25ldC9v
cGVudnN3aXRjaC9kYXRhcGF0aC5jIGIvbmV0L29wZW52c3dpdGNoL2RhdGFwYXRoLmMKPj4gaW5k
ZXggMzMyYjVhMC4uYjJhMzc5NiAxMDA2NDQKPj4gLS0tIGEvbmV0L29wZW52c3dpdGNoL2RhdGFw
YXRoLmMKPj4gKysrIGIvbmV0L29wZW52c3dpdGNoL2RhdGFwYXRoLmMKPj4gQEAgLTQ2MiwxMCAr
NDYyLDggQEAgc3RhdGljIGludCBxdWV1ZV91c2Vyc3BhY2VfcGFja2V0KHN0cnVjdCBkYXRhcGF0
aCAqZHAsIHN0cnVjdCBza19idWZmICpza2IsCj4+ICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgMCwgdXBjYWxsX2luZm8tPmNtZCk7Cj4+ICAgICAgICAgdXBjYWxsLT5kcF9pZmluZGV4ID0g
ZHBfaWZpbmRleDsKPj4KPj4gLSAgICAgICBubGEgPSBubGFfbmVzdF9zdGFydCh1c2VyX3NrYiwg
T1ZTX1BBQ0tFVF9BVFRSX0tFWSk7Cj4+IC0gICAgICAgZXJyID0gb3ZzX25sYV9wdXRfZmxvdyhr
ZXksIGtleSwgdXNlcl9za2IpOwo+PiArICAgICAgIGVyciA9IG92c19ubGFfcHV0X2Zsb3coa2V5
LCBrZXksIE9WU19QQUNLRVRfQVRUUl9LRVksIGZhbHNlLCB1c2VyX3NrYik7Cj4KPiBXZSBuZWVk
IGRpZmZlcmVudCBuYW1lIGhlcmUsIHNpbmNlIGl0IGRvZXMgbm90IG9wZXJhdGUgb24gZmxvdy4g
bWF5YmUKPiBfX292c19ubGFfcHV0X2tleSgpLiB3ZSBjYW4gbW92ZSB0aGUgZnVuY3Rpb24gZGVm
aW5pdGlvbiB0bwo+IGZsb3dfbmV0bGluay5oCgpPSyBzdXJlLiBJJ2xsIGZpeCB0aGlzIHVwIGZv
ciB0aGUgbmV4dCB2ZXJzaW9uLgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fXwpkZXYgbWFpbGluZyBsaXN0CmRldkBvcGVudnN3aXRjaC5vcmcKaHR0cDovL29w
ZW52c3dpdGNoLm9yZy9tYWlsbWFuL2xpc3RpbmZvL2Rldgo=
