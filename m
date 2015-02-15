From: Joe Stringer <joestringer-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC net-next 3/4] openvswitch: Add conntrack action.
Date: Sun, 15 Feb 2015 11:06:55 -0800
Message-ID: <CANr6G5yBW5JNMk3qvAuyD+OgtnhV6vg2E-41DO51bVtyeSWSNg@mail.gmail.com>
References: <1423901633-53789-1-git-send-email-joestringer@nicira.com>
 <1423901633-53789-4-git-send-email-joestringer@nicira.com>
 <20150214195607.GA30752@casper.infradead.org>
 <CANr6G5x19zc8qK0gtPBFzMD02xMxieFqGpv9-nkKyiZ1MzSUwA@mail.gmail.com>
 <54E0B67A.1030000@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
 Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
To: nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <54E0B67A.1030000-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
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

T24gMTUgRmVicnVhcnkgMjAxNSBhdCAwNzowOCwgTmljb2xhcyBEaWNodGVsIDxuaWNvbGFzLmRp
Y2h0ZWxANndpbmQuY29tPiB3cm90ZToKPiBMZSAxNS8wMi8yMDE1IDA1OjQ3LCBKb2UgU3RyaW5n
ZXIgYSDDqWNyaXQgOgo+Cj4+IE9uIDE0IEZlYnJ1YXJ5IDIwMTUgYXQgMTE6NTYsIFRob21hcyBH
cmFmIDx0Z3JhZkBzdXVnLmNoPiB3cm90ZToKPj4+Cj4+PiBPbiAwMi8xNC8xNSBhdCAxMjoxM2Ft
LCBKb2UgU3RyaW5nZXIgd3JvdGU6Cj4+Pgo+Pj4gWy4uXQo+Pj4KPj4+PiArc3RhdGljIGJvb2wg
c2tiX2hhc192YWxpZF9uZmN0KGNvbnN0IHN0cnVjdCBuZXQgKm5ldCwgdTE2IHpvbmUsCj4+Pj4g
KyAgICAgICAgICAgICAgICAgICAgICAgICAgICBjb25zdCBzdHJ1Y3Qgc2tfYnVmZiAqc2tiKQo+
Pj4+ICt7Cj4+Pj4gKyAgICAgZW51bSBpcF9jb25udHJhY2tfaW5mbyBjdGluZm87Cj4+Pj4gKyAg
ICAgc3RydWN0IG5mX2Nvbm4gKmN0ID0gbmZfY3RfZ2V0KHNrYiwgJmN0aW5mbyk7Cj4+Pj4gKwo+
Pj4+ICsgICAgIGlmICghY3QpCj4+Pj4gKyAgICAgICAgICAgICByZXR1cm4gZmFsc2U7Cj4+Pj4g
KyAgICAgaWYgKCFuZXRfZXEobmV0LCBjdC0+Y3RfbmV0KSkKPj4+PiArICAgICAgICAgICAgIHJl
dHVybiBmYWxzZTsKPj4+Cj4+Pgo+Pj4gSSdtIHN1cnByaXNlZCB0aGF0IHRoaXMgaXMgbmVlZGVk
LiBTaG91bGRuJ3Qgd2UgY2FsbCBza2Jfc2NydWJfcGFja2V0KCkKPj4+IGJldHdlZW4gbmFtZXNw
YWNlcyBhbmQgaW52YWxpZGF0ZSB0aGUgY3QgYXNzb2NpYXRlZCB3aXRoIHRoZSBza2IuCj4+Cj4+
Cj4+IFJpZ2h0LCBpdCB3YXMgbW9yZSBvZiBhIGdlbmVyYWwgc2FuaXR5IGNoZWNrIHdoaWNoIGlz
IGxpa2VseSB1bm5lZWRlZC4KPj4gSSdtIG5vdCBhd2FyZSBvZiBhbnkgcGFydGljdWxhciBjYXNl
IHRoYXQgdGhpcyBoYW5kbGVzLgo+Cj4gSSBhZ3JlZSB3aXRoIFRob21hcy4gSWYgd2UgZmFsbCBp
bnRvIHRoaXMgY2FzZSwgaXQncyBwcm9iYWJseSBhIHJlYWwgYnVnIDstKQoKV2UgY2FuIEJVR19P
TigpLCB0aGVuLgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
XwpkZXYgbWFpbGluZyBsaXN0CmRldkBvcGVudnN3aXRjaC5vcmcKaHR0cDovL29wZW52c3dpdGNo
Lm9yZy9tYWlsbWFuL2xpc3RpbmZvL2Rldgo=
