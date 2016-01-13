From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v2] net: preserve IP control block during GSO
 segmentation
Date: Wed, 13 Jan 2016 15:51:12 -0500 (EST)
Message-ID: <20160113.155112.119405358547782630.davem@davemloft.net>
References: <145225570625.30903.13936642758071448458.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: koct9i-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <145225570625.30903.13936642758071448458.stgit@zurg>
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

RnJvbTogS29uc3RhbnRpbiBLaGxlYm5pa292IDxrb2N0OWlAZ21haWwuY29tPgpEYXRlOiBGcmks
IDA4IEphbiAyMDE2IDE1OjIxOjQ2ICswMzAwCgo+IFNrYl9nc29fc2VnbWVudCgpIHVzZXMgc2ti
IGNvbnRyb2wgYmxvY2sgZHVyaW5nIHNlZ21lbnRhdGlvbi4KPiBUaGlzIHBhdGNoIGFkZHMgMzIt
Ynl0ZXMgcm9vbSBmb3IgcHJldmlvdXMgY29udHJvbCBibG9jayB3aGljaAo+IHdpbGwgYmUgY29w
aWVkIGludG8gYWxsIHJlc3VsdGluZyBzZWdtZW50cy4KPiAKPiBUaGlzIHBhdGNoIGZpeGVzIGtl
cm5lbCBjcmFzaCBkdXJpbmcgZnJhZ21lbnRpbmcgZm9yd2FyZGVkIHBhY2tldHMuCj4gRnJhZ21l
bnRhdGlvbiByZXF1aXJlcyB2YWxpZCBJUCBDQiBpbiBza2IgZm9yIGNsZWFyaW5nIGlwIG9wdGlv
bnMuCj4gQWxzbyBwYXRjaCByZW1vdmVzIGN1c3RvbSBzYXZlL3Jlc3RvcmUgaW4gb3ZzIGNvZGUs
IG5vdyBpdCdzIHJlZHVuZGFudC4KPiAKPiBTaWduZWQtb2ZmLWJ5OiBLb25zdGFudGluIEtobGVi
bmlrb3YgPGtvY3Q5aUBnbWFpbC5jb20+Cj4gTGluazogaHR0cDovL2xrbWwua2VybmVsLm9yZy9y
L0NBTFlHTmlQLTBNWi1GRXhWMkh1dFR2RTlVLVFRdGtLU29FLS1LTj1KUUU1U1RZc2pBQUBtYWls
LmdtYWlsLmNvbQoKSWYgdGhpcyB3b3JrcyBJIGRlZmluaXRlbHkgcHJlZmVyIHRoaXMgYXBwcm9h
Y2ggdG8gdGhlIG90aGVyIHBhdGNoCndoZXJlIHRoZSBDQiBpcyBjb3BpZWQgYmFjayBhbmQgZm9y
dGguCgpBbnkgb3RoZXIgcmV2aWV3ZXJzPwpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fXwpkZXYgbWFpbGluZyBsaXN0CmRldkBvcGVudnN3aXRjaC5vcmcKaHR0
cDovL29wZW52c3dpdGNoLm9yZy9tYWlsbWFuL2xpc3RpbmZvL2Rldgo=
