From: Andrzej Hajda <a.hajda@samsung.com>
Subject: Re: [PATCH 00/38] Fixes related to incorrect usage of
	unsigned types
Date: Tue, 22 Sep 2015 11:13:29 +0200
Message-ID: <56011BB9.5030004@samsung.com>
References: <1442842450-29769-1-git-send-email-a.hajda@samsung.com>
 <17571.1442842945@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: linux-mips@linux-mips.org, linux-fbdev@vger.kernel.org,
 linux-sh@vger.kernel.org, brcm80211-dev-list@broadcom.com,
 dri-devel@lists.freedesktop.org, linux-mm@kvack.org, linux-clk@vger.kernel.org,
 linux-leds@vger.kernel.org, Marek Szyprowski <m.szyprowski@samsung.com>,
 devel@driverdev.osuosl.org, linux-rdma@vger.kernel.org,
 linux-cachefs@redhat.com, linux-serial@vger.kernel.org,
 linux-input@vger.kernel.org, linux-media@vger.kernel.org, dev@openvswitch.org,
 rtc-linux@googlegroups.com,
 Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
 intel-gfx@lists.freedesktop.org, linux-omap@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, Andrzej Hajda <a.hajda@samsung.com>,
 linux-api@vger.kernel.org, linux-usb@vger.kernel.org,
 linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
 lustre-devel@lists.lustre.org
To: David Howells <dhowells@redhat.com>
Return-path: <intel-gfx-bounces@lists.freedesktop.org>
In-reply-to: <17571.1442842945@warthog.procyon.org.uk>
List-Unsubscribe: <http://lists.freedesktop.org/mailman/options/intel-gfx>,
 <mailto:intel-gfx-request@lists.freedesktop.org?subject=unsubscribe>
List-Archive: <http://lists.freedesktop.org/archives/intel-gfx>
List-Post: <mailto:intel-gfx@lists.freedesktop.org>
List-Help: <mailto:intel-gfx-request@lists.freedesktop.org?subject=help>
List-Subscribe: <http://lists.freedesktop.org/mailman/listinfo/intel-gfx>,
 <mailto:intel-gfx-request@lists.freedesktop.org?subject=subscribe>
Errors-To: intel-gfx-bounces@lists.freedesktop.org
Sender: "Intel-gfx" <intel-gfx-bounces@lists.freedesktop.org>
List-Id: netdev.vger.kernel.org

T24gMDkvMjEvMjAxNSAwMzo0MiBQTSwgRGF2aWQgSG93ZWxscyB3cm90ZToKPiBBbmRyemVqIEhh
amRhIDxhLmhhamRhLVN6ZTNPM1VVMjJKQkRnaks3eTdUVVFAcHVibGljLmdtYW5lLm9yZz4gd3Jv
dGU6Cj4gCj4+IFNlbWFudGljIHBhdGNoIGZpbmRzIGNvbXBhcmlzb25zIG9mIHR5cGVzOgo+PiAg
ICAgdW5zaWduZWQgPCAwCj4+ICAgICB1bnNpZ25lZCA+PSAwCj4+IFRoZSBmb3JtZXIgaXMgYWx3
YXlzIGZhbHNlLCB0aGUgbGF0dGVyIGlzIGFsd2F5cyB0cnVlLgo+PiBTdWNoIGNvbXBhcmlzb25z
IGFyZSB1c2VsZXNzLCBzbyB0aGVvcmV0aWNhbGx5IHRoZXkgY291bGQgYmUKPj4gc2FmZWx5IHJl
bW92ZWQsIGJ1dCB0aGVpciBwcmVzZW5jZSBxdWl0ZSBvZnRlbiBpbmRpY2F0ZXMgYnVncy4KPiAK
PiBPciBzb21lb25lIGhhcyBsZWZ0IHRoZW0gaW4gYmVjYXVzZSB0aGV5IGRvbid0IG1hdHRlciBh
bmQgdGhlcmUncyB0aGUKPiBwb3NzaWJpbGl0eSB0aGF0IHRoZSB0eXBlIGJlaW5nIHRlc3RlZCBt
aWdodCBiZSBvciBiZWNvbWUgc2lnbmVkIHVuZGVyIHNvbWUKPiBjaXJjdW1zdGFuY2VzLiAgSWYg
dGhlIGNvbXBhcmlzb24gaXMgdXNlbGVzcywgSSdkIGV4cGVjdCB0aGUgY29tcGlsZXIgdG8ganVz
dAo+IGRpc2NhcmQgaXQgLSBmb3Igc3VjaCBjYXNlcyB5b3VyIHBhdGNoIGlzIHBvaW50bGVzcy4K
PiAKPiBJZiBJIGhhdmUsIGZvciBleGFtcGxlOgo+IAo+IAl1bnNpZ25lZCB4Owo+IAo+IAlpZiAo
eCA9PSAwIHx8IHggPiAyNykKPiAJCWdpdmVfYV9yYW5nZV9lcnJvcigpOwo+IAo+IEkgd2lsbCB3
cml0ZSB0aGlzIGFzOgo+IAo+IAl1bnNpZ25lZCB4Owo+IAo+IAlpZiAoeCA8PSAwIHx8IHggPiAy
NykKPiAJCWdpdmVfYV9yYW5nZV9lcnJvcigpOwo+IAo+IGJlY2F1c2UgaXQgdGhhdCBnaXZlcyBh
IHdheSB0byBoYW5kbGUgeCBiZWluZyBjaGFuZ2VkIHRvIHNpZ25lZCBhdCBzb21lIHBvaW50Cj4g
aW4gdGhlIGZ1dHVyZSBmb3Igbm8gY29zdC4gIEluIHdoaWNoIGNhc2UsIHlvdXIgY2hhbmdpbmcg
dGhlIDw9IHRvIGFuID09Cj4gImJlY2F1c2UgdGhlIDwgcGFydCBvZiB0aGUgY2FzZSBpcyB1c2Vs
ZXNzIiBpcyBhcmd1YWJseSB3cm9uZy4KClRoaXMgaXMgd2h5IEkgaGF2ZSBub3QgY2hlY2tlZCBm
b3Igc3VjaCBjYXNlcyAtIEkgaGF2ZSBza2lwcGVkIGNoZWNrcyBvZiB0eXBlCgl1bnNpZ25lZCA8
PSAwCmV4YWN0bHkgZm9yIHRoZSByZWFzb25zIGFib3ZlLgoKSG93ZXZlciBJIGhhdmUgbGVmdCB0
d28gb3RoZXIgY2hlY2tzIGFzIHRoZXkgc2VlbXMgdG8gbWUgbW9yZSBzdXNwaWNpb3VzIC0gdGhl
eQphcmUgYWx3YXlzIHRydWUgb3IgZmFsc2UuIEJ1dCBhcyBEbWl0cnkgYW5kIEFuZHJldyBwb2lu
dGVkIG91dCBMaW51cyBoYXZlIHF1aXRlCnN0cm9uZyBvcGluaW9uIGFnYWluc3QgcmVtb3Zpbmcg
cmFuZ2UgY2hlY2tzIGluIHN1Y2ggY2FzZXMgYXMgaGUgZmluZHMgaXQKY2xlYXJlci4gSSB0aGlu
ayBpdCBhcHBsaWVzIHRvIHBhdGNoZXMgMjktMzYuIEkgYW0gbm90IHN1cmUgYWJvdXQgcGF0Y2hl
cyAyNi0yOCwzNy4KClJlZ2FyZHMKQW5kcnplagoKPiAKPiBEYXZpZAo+IC0tCj4gVG8gdW5zdWJz
Y3JpYmUgZnJvbSB0aGlzIGxpc3Q6IHNlbmQgdGhlIGxpbmUgInVuc3Vic2NyaWJlIGxpbnV4LXdp
cmVsZXNzIiBpbgo+IHRoZSBib2R5IG9mIGEgbWVzc2FnZSB0byBtYWpvcmRvbW8tdTc5dXdYTDI5
VFk3Nloyck01bUhYQUBwdWJsaWMuZ21hbmUub3JnCj4gTW9yZSBtYWpvcmRvbW8gaW5mbyBhdCAg
aHR0cDovL3ZnZXIua2VybmVsLm9yZy9tYWpvcmRvbW8taW5mby5odG1sCj4gCgpfX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpJbnRlbC1nZnggbWFpbGluZyBs
aXN0CkludGVsLWdmeEBsaXN0cy5mcmVlZGVza3RvcC5vcmcKaHR0cDovL2xpc3RzLmZyZWVkZXNr
dG9wLm9yZy9tYWlsbWFuL2xpc3RpbmZvL2ludGVsLWdmeAo=
