From: Felix Fietkau <nbd@openwrt.org>
Subject: Re: [RFC][PATCH 2/2] bgmac: pass received packet to
 the netif instead of copying it
Date: Thu, 15 Aug 2013 13:47:34 +0200
Message-ID: <520CBFD6.6030600@openwrt.org>
References: <1376243355-5740-1-git-send-email-zajec5@gmail.com>
 <1376243355-5740-2-git-send-email-zajec5@gmail.com>
 <CACna6rwtLw-Aiz3amMvTBwWsi0OWo5f2yMCF9e8DeCjKLOGDEA@mail.gmail.com>
Reply-To: OpenWrt Development List <openwrt-devel@lists.openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Network Development <netdev@vger.kernel.org>,
 Jonas Gorski <jogo@openwrt.org>, Hauke Mehrtens <hauke@hauke-m.de>
To: OpenWrt Development List <openwrt-devel@lists.openwrt.org>
Return-path: <openwrt-devel-bounces@lists.openwrt.org>
In-Reply-To: <CACna6rwtLw-Aiz3amMvTBwWsi0OWo5f2yMCF9e8DeCjKLOGDEA@mail.gmail.com>
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

T24gMjAxMy0wOC0xNSAxOjM2IFBNLCBSYWZhxYIgTWnFgmVja2kgd3JvdGU6Cj4gMjAxMy84LzEx
IFJhZmHFgiBNacWCZWNraSA8emFqZWM1QGdtYWlsLmNvbT46Cj4+IEl0IG1ha2VzIG1vcmUgc2Vu
c2UgdG8gYWxsb2NhdGUgbmV3IChlbXB0eSkgc2tiIGFuZCBwYXNzIGl0IHRvIHRoZQo+PiBoYXJk
d2FyZS4gVGhhdCB3YXkgd2UgYXZvaWQgY29weWluZyB3aG9sZSBwYWNrZXQgaW50byBuZXcgc2ti
IHdoaWNoCj4+IHNob3VsZCByZXN1bHQgaW4gYmV0dGVyIHBlcmZvcm1hbmNlLgo+IAo+IEkgZGlk
IHNvbWUgdGVzdGluZyBvZiB0aGlzIHBhdGNoIHVzaW5nICJwZXJmIiB0b29sIGFuZCBpcGVyZiAt
cwo+IHJ1bm5pbmcgb24gdGhlIE9wZW5XcnQgbWFjaGluZSAod2l0aCBiZ21hYyBzdXBwb3J0ZWQg
aGFyZHdhcmUpLgo+IAo+IFNvIHlvdSBjYW4gc2VlIHRoYXQgX19jb3B5X3VzZXJfY29tbW9uIHVz
YWdlIGhhcyByZWFsbHkgZGVjcmVhc2VkIHdpdGgKPiB0aGlzIHBhdGNoIQo+IAo+IFVuZm9ydHVu
YXRlbHkgaXQgZGlkbid0IHJlc3VsdCBpbiBiZXR0ZXIgcGVyZm9ybWFuY2UuLi4gbm8gaWRlYSB3
aHkgOigKUnVubmluZyBpcGVyZiBvbiB0aGUgcm91dGVyIGlzIG5vdCB1c2VmdWwgYXMgYW4gaW5k
aWNhdG9yIG9mIHJvdXRpbmcKcGVyZm9ybWFuY2UuIFBsZWFzZSBmb2N1cyBvbiB0ZXN0cyB3aGVy
ZSB5b3Ugb25seSBwdXNoIHRyYWZmaWMgdGhyb3VnaAp0aGUgcm91dGVyLCBub3QgZGlyZWN0bHkg
dG8gaXQuCgotIEZlbGl4Cl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fCm9wZW53cnQtZGV2ZWwgbWFpbGluZyBsaXN0Cm9wZW53cnQtZGV2ZWxAbGlzdHMub3Bl
bndydC5vcmcKaHR0cHM6Ly9saXN0cy5vcGVud3J0Lm9yZy9jZ2ktYmluL21haWxtYW4vbGlzdGlu
Zm8vb3BlbndydC1kZXZlbAo=
