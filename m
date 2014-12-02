From: "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net] gso: do GSO for local skb with size
	bigger than MTU
Date: Tue, 2 Dec 2014 19:34:01 +0200
Message-ID: <20141202173401.GB4126@redhat.com>
References: <1417156385-18276-1-git-send-email-fan.du@intel.com>
 <1417158128.3268.2@smtp.corp.redhat.com>
 <5A90DA2E42F8AE43BC4A093BF0678848DED92B@SHSMSX104.ccr.corp.intel.com>
 <20141201135225.GA16814@casper.infradead.org>
 <20141202154839.GB5344@t520.home>
 <20141202170927.GA9457@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 'Jason Wang' <jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "Du, Fan" <fan.du-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
 "fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org" <fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>, "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20141202170927.GA9457-FZi0V3Vbi30CUdFEqe4BF2D2FQJk+8+b@public.gmane.org>
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

T24gVHVlLCBEZWMgMDIsIDIwMTQgYXQgMDU6MDk6MjdQTSArMDAwMCwgVGhvbWFzIEdyYWYgd3Jv
dGU6Cj4gT24gMTIvMDIvMTQgYXQgMDE6NDhwbSwgRmxhdmlvIExlaXRuZXIgd3JvdGU6Cj4gPiBX
aGF0IGFib3V0IGNvbnRhaW5lcnMgb3IgYW55IG90aGVyIHZpcnR1YWxpemF0aW9uIGVudmlyb25t
ZW50IHRoYXQKPiA+IGRvZXNuJ3QgdXNlIFZpcnRpbz8KPiAKPiBUaGUgaG9zdCBjYW4gZGljdGF0
ZSB0aGUgTVRVIGluIHRoYXQgY2FzZSBmb3IgYm90aCB2ZXRoIG9yIE9WUwo+IGludGVybmFsIHdo
aWNoIHdvdWxkIGJlIHByaW1hcnkgY29udGFpbmVyIHBsdW1iaW5nIHRlY2huaXF1ZXMuCgpJdCB0
eXBpY2FsbHkgY2FuJ3QgZG8gdGhpcyBlYXNpbHkgZm9yIFZNcyB3aXRoIGVtdWxhdGVkIGRldmlj
ZXM6CnJlYWwgZXRoZXJuZXQgdXNlcyBhIGZpeGVkIE1UVS4KCklNSE8gaXQncyBjb25mdXNpbmcg
dG8gc3VnZ2VzdCBNVFUgYXMgYSBmaXggZm9yIHRoaXMgYnVnLCBpdCdzCmFuIHVucmVsYXRlZCBv
cHRpbWl6YXRpb24uCklDTVBfREVTVF9VTlJFQUNIL0lDTVBfRlJBR19ORUVERUQgaXMgdGhlIHJp
Z2h0IGZpeCBoZXJlLgoKCj4gaXZzaG1lbSB3b3VsZCBuZWVkIGl0J3Mgb3duIGZpeC4KX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KZGV2IG1haWxpbmcgbGlz
dApkZXZAb3BlbnZzd2l0Y2gub3JnCmh0dHA6Ly9vcGVudnN3aXRjaC5vcmcvbWFpbG1hbi9saXN0
aW5mby9kZXYK
