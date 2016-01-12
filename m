From: Cong Wang <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] net: preserve IP control block during GSO
	segmentation
Date: Mon, 11 Jan 2016 16:58:24 -0800
Message-ID: <CAM_iQpUO4aE_UybNYrFw+u=LWnF3OcC5jQ+ADsK1XobjBwUeEA@mail.gmail.com>
References: <145225444176.22215.2003378381077166898.stgit@zurg>
 <063D6719AE5E284EB5DD2968C1650D6D1CCC01BA@AcuExch.aculab.com>
 <56935DB5.1030502@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org,
 Linux Kernel Network Developers <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Zang MingJie <zealot0630-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <56935DB5.1030502-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
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

T24gU3VuLCBKYW4gMTAsIDIwMTYgYXQgMTE6NDUgUE0sIFphbmcgTWluZ0ppZSA8emVhbG90MDYz
MEBnbWFpbC5jb20+IHdyb3RlOgo+IE9uIDAxLzA4LzIwMTYgMDg6MTMgUE0sIERhdmlkIExhaWdo
dCB3cm90ZToKPj4KPj4gWW91IGNvdWxkIHNldCBTS0JfU0dPX0NCX09GRlNFVCB0byBzaXplb2Yg
KChza2IpLT5jYikgLSBzaXplb2YgKHN0cnVjdAo+PiBza2JfZ3NvX2NiKQo+PiBzbyB0aGF0IHRo
ZSBlbmQgb2YgJ2NiJyBpcyBhbHdheXMgdXNlZC4KPj4gKEFzc3VtaW5nIHRoZSBmb3JtZXIgaXMg
YSBtdWx0aXBsZSBvZiA0LikKPj4KPj4gSXQgbWlnaHQgYmUgd29ydGggdXNpbmcgYW4gb24tc3Rh
Y2sgc3RydWN0dXJlIHBhc3NlZCB0aHJvdWdoIGFzIGEgc2VwYXJhdGUKPj4gcGFyYW1ldGVyIC0g
aXQgZG9lc24ndCBsb29rIGFzIHRob3VnaCBpdCBoYXMgdG8gYmUgcXVldWVkIHdpdGggdGhlIHNr
Yi4KPj4gKENsZWFybHkgYSBiaWdnZXIgY2hhbmdlLikKPgo+Cj4gSSB3b3VsZCBkZWZpbml0ZWx5
IHByZWZlciB0aGUgc3RhY2sgc3RydWN0dXJlLgo+Cj4gQXMgYSBrZXJuZWwgZGV2ZWxvcGVyLCBz
b21ldGltZSBJIGNhbiBoYXJkbHkgZmlndXJlIG91dCB3aGljaCBzdHJ1Y3QgY3VycmVudAo+IGNi
IGlzIHdpdGhvdXQgZGVidWcgaXQsIGFuZCB0aGUgd29yc3QgdGhleSBhcmUgbm90IGRvY3VtZW50
ZWQgYW55d2hlcmUuIEkKPiBjYW4gaGFyZGx5IGtub3cgdGhlIGxpZmUgdGltZSBvZiB0aGUgY2Ig
dHlwZXMuCgpOQUsuCgpTa2IgY29udHJvbCBibG9jayB3YXMgbm90IGRlc2lnbmVkIHRvIGJlIHVz
ZWQgbGlrZSBhIHN0YWNrIGJ1dCBsaWtlIGEgdW5pb24KZm9yIGRpZmZlcmVudCBsYXllcnMsIGp1
c3QgdGhhdCBwZW9wbGUgYmVnaW4gdG8gbWVzcyBpdCB1cC4KX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX18KZGV2IG1haWxpbmcgbGlzdApkZXZAb3BlbnZzd2l0
Y2gub3JnCmh0dHA6Ly9vcGVudnN3aXRjaC5vcmcvbWFpbG1hbi9saXN0aW5mby9kZXYK
