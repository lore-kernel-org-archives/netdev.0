From: David Lang <david@lang.hm>
Subject: Re: [Make-wifi-fast] OpenWRT wrong adjustment of fq_codel
 defaults (Was: fq_codel_drop vs a udp flood)
Date: Mon, 16 May 2016 01:12:59 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1605160110270.1574@nftneq.ynat.uz>
References: <CAA93jw6QLyx9EaS+ntB0D3duoysu_Z-UYyQfHnRa=pfqPDfWOw@mail.gmail.com>
 <CACiydbKUu11=zWitkDha0ddgk1-G_Z4-e1+=9ky776VktF5HHg@mail.gmail.com>
 <1462201620.5535.250.camel@edumazet-glaptop3.roam.corp.google.com>
 <CACiydbKeKUENncrc-NmYRcku-DGVeGqqzYMqsCqKdxPsR7yUOQ@mail.gmail.com>
 <1462205669.5535.254.camel@edumazet-glaptop3.roam.corp.google.com>
 <CACiydbL26Jj3EcEL4EmqaH=1Dm-Q0dpVwoWxqUSZ7ry10bRgeg@mail.gmail.com>
 <1462464776.13075.18.camel@edumazet-glaptop3.roam.corp.google.com>
 <CACiydbJYrFRMJvSHM6tJYWR8vmgV3xxnSUQsb-h5WcnLW=KXoQ@mail.gmail.com>
 <1462476207.13075.20.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160506114243.4eb4f95e@redhat.com> <20160506144740.210901f5@redhat.com>
 <CACiydbL3qZrvZ4a_OUXiN0dp7qdqOktaQdAUdfOpKkZ1OfEZbA@mail.gmail.com>
 <CACiydb+A_vFNdp7tbw67Rnp+kHwt5GsLa+Su+pO8YmOZYp_KHg@mail.gmail.com>
 <CAA93jw4XeMSxiTLHWZ2b=F9ni7wz9RpkWDdhTh99gn4Mf1aWjA@mail.gmail.com>
 <CACiydbLcYe=2VLb3W9i-i2FGALwxJK=oO8RcZWjmj3YPGObK3Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; Format="flowed"
Content-Transfer-Encoding: base64
Cc: make-wifi-fast@lists.bufferbloat.net,
 =?ISO-8859-2?Q?Rafa=B3_Mi=B3ecki?= <zajec5@gmail.com>,
 ath10k <ath10k@lists.infradead.org>,
 "codel@lists.bufferbloat.net" <codel@lists.bufferbloat.net>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 OpenWrt Development List <openwrt-devel@lists.openwrt.org>,
 Felix Fietkau <nbd@nbd.name>
To: Roman Yeryomin <leroi.lists@gmail.com>
Return-path: <codel-bounces@lists.bufferbloat.net>
In-Reply-To: <CACiydbLcYe=2VLb3W9i-i2FGALwxJK=oO8RcZWjmj3YPGObK3Q@mail.gmail.com>
List-Unsubscribe: <https://lists.bufferbloat.net/options/codel>,
 <mailto:codel-request@lists.bufferbloat.net?subject=unsubscribe>
List-Archive: <https://lists.bufferbloat.net/pipermail/codel>
List-Post: <mailto:codel@lists.bufferbloat.net>
List-Help: <mailto:codel-request@lists.bufferbloat.net?subject=help>
List-Subscribe: <https://lists.bufferbloat.net/listinfo/codel>,
 <mailto:codel-request@lists.bufferbloat.net?subject=subscribe>
Errors-To: codel-bounces@lists.bufferbloat.net
Sender: "Codel" <codel-bounces@lists.bufferbloat.net>
List-Id: netdev.vger.kernel.org

T24gTW9uLCAxNiBNYXkgMjAxNiwgUm9tYW4gWWVyeW9taW4gd3JvdGU6Cgo+IE9uIDYgTWF5IDIw
MTYgYXQgMjI6NDMsIERhdmUgVGFodCA8ZGF2ZS50YWh0QGdtYWlsLmNvbT4gd3JvdGU6Cj4+IE9u
IEZyaSwgTWF5IDYsIDIwMTYgYXQgMTE6NTYgQU0sIFJvbWFuIFllcnlvbWluIDxsZXJvaS5saXN0
c0BnbWFpbC5jb20+IHdyb3RlOgo+Pj4gT24gNiBNYXkgMjAxNiBhdCAyMTo0MywgUm9tYW4gWWVy
eW9taW4gPGxlcm9pLmxpc3RzQGdtYWlsLmNvbT4gd3JvdGU6Cj4+Pj4gT24gNiBNYXkgMjAxNiBh
dCAxNTo0NywgSmVzcGVyIERhbmdhYXJkIEJyb3VlciA8YnJvdWVyQHJlZGhhdC5jb20+IHdyb3Rl
Ogo+Pj4+Pgo+Cj4+IFRoYXQgaXMgdG9vIGxvdyBhIGxpbWl0LCBhbHNvLCBmb3Igbm9ybWFsIHVz
ZS4gQW5kOgo+PiBmb3IgdGhlIHB1cnBvc2Ugb2YgdGhpcyBwYXJ0aWN1bGFyIFVEUCB0ZXN0LCBm
bG93cyAxNiBpcyBvaywgYnV0IG5vdAo+PiBpZGVhbC4KPgo+IEkgcGxheWVkIHdpdGggZGlmZmVy
ZW50IGNvbWJpbmF0aW9ucywgaXQgZG9lc24ndCBtYWtlIGFueQo+IChzaWduaWZpY2FudCkgZGlm
ZmVyZW5jZTogMjAtMzBNYnBzLCBub3QgbW9yZS4KPiBXaGF0IG51bWJlcnMgd291bGQgeW91IHBy
b3Bvc2U/CgpIb3cgbWFueSBkaWZmZXJlbnQgZmxvd3MgZGlkIHlvdSBoYXZlIGdvaW5nIGF0IG9u
Y2U/IEkgYmVsaWV2ZSB0aGF0IHRoZSByZWFzb24gCmZvciBoaWdoZXIgbnVtYmVycyBpc24ndCBm
b3IgdGhyb3VnaHB1dCwgYnV0IHRvIGFsbG93IGZvciBtb3JlIGZsb3dzIHRvIGJlIAppc29sYXRl
ZCBmcm9tIGVhY2ggb3RoZXIuIElmIHlvdSBoYXZlIHRvbyBmZXcgYnVja2V0cywgZGlmZmVyZW50
IGZsb3dzIHdpbGwgZW5kIAp1cCBiZWluZyBjb21iaW5lZCBpbnRvIG9uZSBidWNrZXQgc28gdGhh
dCBvbmUgd2lsbCBhZmZlY3QgdGhlIG90aGVyIG1vcmUuCgpEYXZpZCBMYW5nCl9fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fCkNvZGVsIG1haWxpbmcgbGlzdApD
b2RlbEBsaXN0cy5idWZmZXJibG9hdC5uZXQKaHR0cHM6Ly9saXN0cy5idWZmZXJibG9hdC5uZXQv
bGlzdGluZm8vY29kZWwK
