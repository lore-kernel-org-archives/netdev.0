From: Konstantin Khlebnikov <koct9i-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] net: preserve IP control block during GSO
	segmentation
Date: Fri, 8 Jan 2016 15:10:31 +0300
Message-ID: <CALYGNiMDqQyZYivuWahMkaqbJs0aLvzZGj0pUnxbd_XhkHLvUA@mail.gmail.com>
References: <145225444176.22215.2003378381077166898.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, Florian Westphal <fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>,
 Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Cong Wang <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Linux Kernel Network Developers <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <145225444176.22215.2003378381077166898.stgit@zurg>
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

T24gRnJpLCBKYW4gOCwgMjAxNiBhdCAzOjAwIFBNLCBLb25zdGFudGluIEtobGVibmlrb3YgPGtv
Y3Q5aUBnbWFpbC5jb20+IHdyb3RlOgo+IFNrYl9nc29fc2VnbWVudCgpIHVzZXMgc2tiIGNvbnRy
b2wgYmxvY2sgZHVyaW5nIHNlZ21lbnRhdGlvbi4KPiBUaGlzIHBhdGNoIGFkZHMgMzItYnl0ZXMg
cm9vbSBmb3IgcHJldmlvdXMgY29udHJvbCBibG9jayB3aGljaAo+IHdpbGwgYmUgY29waWVkIGlu
dG8gYWxsIHJlc3VsdGluZyBzZWdtZW50cy4KPgo+IFRoaXMgcGF0Y2ggZml4ZXMga2VybmVsIGNy
YXNoIGR1cmluZyBmcmFnbWVudGluZyBmb3J3YXJkZWQgcGFja2V0cy4KPiBGcmFnbWVudGF0aW9u
IHJlcXVpcmVzIHZhbGlkIElQIENCIGluIHNrYiBmb3IgY2xlYXJpbmcgaXAgb3B0aW9ucy4KPiBB
bHNvIHBhdGNoIHJlbW92ZXMgY3VzdG9tIHNhdmUvcmVzdG9yZSBpbiBvdnMgY29kZSwgbm93IGl0
J3MgcmVkdW5kYW50Lgo+Cj4gU2lnbmVkLW9mZi1ieTogS29uc3RhbnRpbiBLaGxlYm5pa292IDxr
b2N0OWlAZ21haWwuY29tPgo+IExpbms6IGh0dHA6Ly9sa21sLmtlcm5lbC5vcmcvci9DQUxZR05p
UC0wTVotRkV4VjJIdXRUdkU5VS1RUXRrS1NvRS0tS049SlFFNVNUWXNqQUFAbWFpbC5nbWFpbC5j
b20KClRoaXMgcGF0Y2ggaXMgYWx0ZXJuYXRpdmUgZm9yIFtQQVRDSF0gbmV0OiBwcmV2ZW50IGNv
cnJ1cHRpb24gb2Ygc2tiIHdoZW4gdXNpbmcKc2tiX2dzb19zZWdtZW50IGJ5IFRoYWRldSBMaW1h
IGRlIFNvdXphIENhc2NhcmRvLiBUaGlzIHZlcnNpb24gaGF2ZQpubyBzdGFjayBhbGxvY2F0aW9u
cyBhbmQgbm8gY2hhbmdlcyBpbiBjb2RlLiBJdCBqdXN0IHNoaWZ0cyBnc28gY2IuCl9fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fCmRldiBtYWlsaW5nIGxpc3QK
ZGV2QG9wZW52c3dpdGNoLm9yZwpodHRwOi8vb3BlbnZzd2l0Y2gub3JnL21haWxtYW4vbGlzdGlu
Zm8vZGV2Cg==
