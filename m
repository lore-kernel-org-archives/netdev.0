From: Roman Yeryomin <leroi.lists@gmail.com>
Subject: Re: [Make-wifi-fast] OpenWRT wrong adjustment of
 fq_codel defaults (Was: [Codel] fq_codel_drop vs a udp flood)
Date: Mon, 16 May 2016 11:26:16 +0300
Message-ID: <CACiydbL_dfBU=8m=gSSiR6HwdVU+z2WMeQMjP+boNhGe19_7Sg@mail.gmail.com>
References: <CAA93jw6QLyx9EaS+ntB0D3duoysu_Z-UYyQfHnRa=pfqPDfWOw@mail.gmail.com>
 <CACiydbKUu11=zWitkDha0ddgk1-G_Z4-e1+=9ky776VktF5HHg@mail.gmail.com>
 <1462201620.5535.250.camel@edumazet-glaptop3.roam.corp.google.com>
 <CACiydbKeKUENncrc-NmYRcku-DGVeGqqzYMqsCqKdxPsR7yUOQ@mail.gmail.com>
 <1462205669.5535.254.camel@edumazet-glaptop3.roam.corp.google.com>
 <CACiydbL26Jj3EcEL4EmqaH=1Dm-Q0dpVwoWxqUSZ7ry10bRgeg@mail.gmail.com>
 <1462464776.13075.18.camel@edumazet-glaptop3.roam.corp.google.com>
 <CACiydbJYrFRMJvSHM6tJYWR8vmgV3xxnSUQsb-h5WcnLW=KXoQ@mail.gmail.com>
 <1462476207.13075.20.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160506114243.4eb4f95e@redhat.com>
 <20160506144740.210901f5@redhat.com>
 <CACiydbL3qZrvZ4a_OUXiN0dp7qdqOktaQdAUdfOpKkZ1OfEZbA@mail.gmail.com>
 <CACiydb+A_vFNdp7tbw67Rnp+kHwt5GsLa+Su+pO8YmOZYp_KHg@mail.gmail.com>
 <CAA93jw4XeMSxiTLHWZ2b=F9ni7wz9RpkWDdhTh99gn4Mf1aWjA@mail.gmail.com>
 <CACiydbLcYe=2VLb3W9i-i2FGALwxJK=oO8RcZWjmj3YPGObK3Q@mail.gmail.com>
 <alpine.DEB.2.02.1605160110270.1574@nftneq.ynat.uz>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: make-wifi-fast@lists.bufferbloat.net, Dave Taht <dave.taht@gmail.com>,
 ath10k <ath10k@lists.infradead.org>,
 "codel@lists.bufferbloat.net" <codel@lists.bufferbloat.net>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 OpenWrt Development List <openwrt-devel@lists.openwrt.org>
To: David Lang <david@lang.hm>
Return-path: <openwrt-devel-bounces@lists.openwrt.org>
In-Reply-To: <alpine.DEB.2.02.1605160110270.1574@nftneq.ynat.uz>
List-Unsubscribe: <https://lists.openwrt.org/cgi-bin/mailman/options/openwrt-devel>,
 <mailto:openwrt-devel-request@lists.openwrt.org?subject=unsubscribe>
List-Archive: <http://lists.openwrt.org/pipermail/openwrt-devel/>
List-Post: <mailto:openwrt-devel@lists.openwrt.org>
List-Help: <mailto:openwrt-devel-request@lists.openwrt.org?subject=help>
List-Subscribe: <https://lists.openwrt.org/cgi-bin/mailman/listinfo/openwrt-devel>,
 <mailto:openwrt-devel-request@lists.openwrt.org?subject=subscribe>
Errors-To: openwrt-devel-bounces@lists.openwrt.org
Sender: "openwrt-devel" <openwrt-devel-bounces@lists.openwrt.org>
List-Id: netdev.vger.kernel.org

T24gMTYgTWF5IDIwMTYgYXQgMTE6MTIsIERhdmlkIExhbmcgPGRhdmlkQGxhbmcuaG0+IHdyb3Rl
Ogo+IE9uIE1vbiwgMTYgTWF5IDIwMTYsIFJvbWFuIFllcnlvbWluIHdyb3RlOgo+Cj4+IE9uIDYg
TWF5IDIwMTYgYXQgMjI6NDMsIERhdmUgVGFodCA8ZGF2ZS50YWh0QGdtYWlsLmNvbT4gd3JvdGU6
Cj4+Pgo+Pj4gT24gRnJpLCBNYXkgNiwgMjAxNiBhdCAxMTo1NiBBTSwgUm9tYW4gWWVyeW9taW4g
PGxlcm9pLmxpc3RzQGdtYWlsLmNvbT4KPj4+IHdyb3RlOgo+Pj4+Cj4+Pj4gT24gNiBNYXkgMjAx
NiBhdCAyMTo0MywgUm9tYW4gWWVyeW9taW4gPGxlcm9pLmxpc3RzQGdtYWlsLmNvbT4gd3JvdGU6
Cj4+Pj4+Cj4+Pj4+IE9uIDYgTWF5IDIwMTYgYXQgMTU6NDcsIEplc3BlciBEYW5nYWFyZCBCcm91
ZXIgPGJyb3VlckByZWRoYXQuY29tPgo+Pj4+PiB3cm90ZToKPj4+Pj4+Cj4+Pj4+Pgo+Pgo+Pj4g
VGhhdCBpcyB0b28gbG93IGEgbGltaXQsIGFsc28sIGZvciBub3JtYWwgdXNlLiBBbmQ6Cj4+PiBm
b3IgdGhlIHB1cnBvc2Ugb2YgdGhpcyBwYXJ0aWN1bGFyIFVEUCB0ZXN0LCBmbG93cyAxNiBpcyBv
aywgYnV0IG5vdAo+Pj4gaWRlYWwuCj4+Cj4+Cj4+IEkgcGxheWVkIHdpdGggZGlmZmVyZW50IGNv
bWJpbmF0aW9ucywgaXQgZG9lc24ndCBtYWtlIGFueQo+PiAoc2lnbmlmaWNhbnQpIGRpZmZlcmVu
Y2U6IDIwLTMwTWJwcywgbm90IG1vcmUuCj4+IFdoYXQgbnVtYmVycyB3b3VsZCB5b3UgcHJvcG9z
ZT8KPgo+Cj4gSG93IG1hbnkgZGlmZmVyZW50IGZsb3dzIGRpZCB5b3UgaGF2ZSBnb2luZyBhdCBv
bmNlPyBJIGJlbGlldmUgdGhhdCB0aGUKPiByZWFzb24gZm9yIGhpZ2hlciBudW1iZXJzIGlzbid0
IGZvciB0aHJvdWdocHV0LCBidXQgdG8gYWxsb3cgZm9yIG1vcmUgZmxvd3MKPiB0byBiZSBpc29s
YXRlZCBmcm9tIGVhY2ggb3RoZXIuIElmIHlvdSBoYXZlIHRvbyBmZXcgYnVja2V0cywgZGlmZmVy
ZW50IGZsb3dzCj4gd2lsbCBlbmQgdXAgYmVpbmcgY29tYmluZWQgaW50byBvbmUgYnVja2V0IHNv
IHRoYXQgb25lIHdpbGwgYWZmZWN0IHRoZSBvdGhlcgo+IG1vcmUuCgpJJ20gdGVzdGluZyB3aXRo
IG9uZSBmbG93LCBJIG5ldmVyIHNhdyBiaWdnZXIgcGVyZm9ybWFuY2Ugd2l0aCBtb3JlCmZsb3dz
IChlLmcuIC1QOCB0byBpcGVyZjMpLgoKUmVnYXJkcywKUm9tYW4KX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX18Kb3BlbndydC1kZXZlbCBtYWlsaW5nIGxpc3QK
b3BlbndydC1kZXZlbEBsaXN0cy5vcGVud3J0Lm9yZwpodHRwczovL2xpc3RzLm9wZW53cnQub3Jn
L2NnaS1iaW4vbWFpbG1hbi9saXN0aW5mby9vcGVud3J0LWRldmVsCg==
