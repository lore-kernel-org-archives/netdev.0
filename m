From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: enable GRO by default for vlan
	devices
Date: Thu, 16 Sep 2010 00:28:11 +0200
Message-ID: <1284589691.2462.85.camel@edumazet-laptop>
References: <20100914.213544.112598547.davem@davemloft.net>
	<20100915163749.GA4191@mmm.home.ifup.org>
	<1284570520.2462.5.camel@edumazet-laptop>
	<20100915.101418.59680213.davem@davemloft.net>
	<1284571476.2293.5.camel@achroite.uk.solarflarecom.com>
	<20100915192424.GE4191@mmm.home.ifup.org>
	<1284588203.2462.81.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: e1000-devel@lists.sourceforge.net, bruce.w.allan@intel.com,
	jesse.brandeburg@intel.com, john.ronciak@intel.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>
To: Brandon Philips <bphilips@suse.de>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1284588203.2462.81.camel@edumazet-laptop>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

TGUgamV1ZGkgMTYgc2VwdGVtYnJlIDIwMTAgw6AgMDA6MDMgKzAyMDAsIEVyaWMgRHVtYXpldCBh
IMOpY3JpdCA6Cj4gTGUgbWVyY3JlZGkgMTUgc2VwdGVtYnJlIDIwMTAgw6AgMTI6MjQgLTA3MDAs
IEJyYW5kb24gUGhpbGlwcyBhIMOpY3JpdCA6Cj4gPiBDdXJyZW50bHkgdmxhbiBkZXZpY2VzIGRv
bid0IGhhdmUgR1JPIGJ5IGRlZmF1bHQgYXMgbm9uZSBvZiB0aGUgRXRoZXJuZXQKPiA+IGRyaXZl
cnMgYWRkIE5FVElGX0ZfR1JPIHRvIHRoZWlyIHZsYW5fZmVhdHVyZXMuCj4gPiAKPiA+IEFzIEdS
TyBpcyBhIHNvZnR3YXJlIGZlYXR1cmUgYWRkIEdSTyB0byBkZXYtPnZsYW5fZmVhdHVyZXMgaW4K
PiA+IHJlZ2lzdGVyX25ldGRldmljZSgpIGFuZCBsZXQgdmxhbl9kZXZfaW5pdCgpIHRha2UgY2Fy
ZSB0aGF0IGl0IGdldHMKPiA+IGVuYWJsZWQgb25seSB3aGVuIGRldi0+ZmVhdHVyZXMgaGFzIE5F
VElGX0ZfR1JPIHRvby4KPiA+IAo+ID4gU2lnbmVkLW9mZi1ieTogQnJhbmRvbiBQaGlsaXBzIDxi
cGhpbGlwc0BzdXNlLmRlPgo+ID4gCj4gCj4gQWNrZWQtYnk6IEVyaWMgRHVtYXpldCA8ZXJpYy5k
dW1hemV0QGdtYWlsLmNvbT4KPiAKCkJUVywgd2UgaGF2ZSBhIHNpbWlsYXIgcHJvYmxlbSBmb3Ig
Ym9uZGluZyAoIEdSTyBpcyBkaXNhYmxlZCApCgojIGV0aHRvb2wgLUsgYm9uZDAgZ3JvIG9mZgoj
IGV0aHRvb2wgLUsgYm9uZDAgZ3JvIG9uCkNhbm5vdCBzZXQgZGV2aWNlIEdSTyBzZXR0aW5nczog
SW52YWxpZCBhcmd1bWVudAoKU2FtZSBmb3IgdmxhbnMgb24gdG9wIG9mIGJvbmQwCgoKCgotLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0KU3RhcnQgdW5jb3ZlcmluZyB0aGUgbWFueSBhZHZhbnRhZ2VzIG9m
IHZpcnR1YWwgYXBwbGlhbmNlcwphbmQgc3RhcnQgdXNpbmcgdGhlbSB0byBzaW1wbGlmeSBhcHBs
aWNhdGlvbiBkZXBsb3ltZW50IGFuZAphY2NlbGVyYXRlIHlvdXIgc2hpZnQgdG8gY2xvdWQgY29t
cHV0aW5nLgpodHRwOi8vcC5zZi5uZXQvc2Z1L25vdmVsbC1zZmRldjJkZXYKX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KRTEwMDAtZGV2ZWwgbWFpbGluZyBs
aXN0CkUxMDAwLWRldmVsQGxpc3RzLnNvdXJjZWZvcmdlLm5ldApodHRwczovL2xpc3RzLnNvdXJj
ZWZvcmdlLm5ldC9saXN0cy9saXN0aW5mby9lMTAwMC1kZXZlbApUbyBsZWFybiBtb3JlIGFib3V0
IEludGVsJiMxNzQ7IEV0aGVybmV0LCB2aXNpdCBodHRwOi8vY29tbXVuaXRpZXMuaW50ZWwuY29t
L2NvbW11bml0eS93aXJlZAo=
