From: David Decotigny <david.decotigny@google.com>
Subject: [PATCH net-next v2 4/4] net-e1000e: Report carrier in
	loopback mode
Date: Tue, 22 Nov 2011 11:23:38 -0800
Message-ID: <9f22e42c3077643fe66221eb180be6e66a0ef32a.1321989502.git.david.decotigny@google.com>
References: <cover.1321989502.git.david.decotigny@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: David Decotigny <david.decotigny@google.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	=?UTF-8?q?Maciej=20=C5=BBenczykowski?= <zenczykowski@gmail.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <cover.1321989502.git.david.decotigny@google.com>
In-Reply-To: <cover.1321989502.git.david.decotigny@google.com>
References: <cover.1321989502.git.david.decotigny@google.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

RnJvbTogTWFjaWVqIMW7ZW5jenlrb3dza2kgPHplbmN6eWtvd3NraUBnbWFpbC5jb20+CgpXaGVu
IGludGVyZmFjZSBpcyBjb25maWd1cmVkIGluIGxvb3BiYWNrIG1vZGUsIGZvcmNlIGNhcnJpZXIg
Y2hlY2sKcG9zaXRpdmUuICBUaGlzIGlzIHVzZWZ1bCB3aGVuIGludGVyZmFjZSBkb2VzIG5vdCBo
YXZlIGNhcnJpZXIgYW5kCnRlc3QgcHV0cyB0aGUgaW50ZXJmYWNlIGluIGxvb3BiYWNrIG1vZGUu
CgpUZXN0ZWQ6IHBrdGdlbiBsb29wYmFjayBvbiA4MDAwM0VTMkxBTgoKClNpZ25lZC1vZmYtYnk6
IERhdmlkIERlY290aWdueSA8ZGF2aWQuZGVjb3RpZ255QGdvb2dsZS5jb20+Ci0tLQogZHJpdmVy
cy9uZXQvZXRoZXJuZXQvaW50ZWwvZTEwMDBlL3BoeS5jIHwgICAgNSArKysrKwogMSBmaWxlcyBj
aGFuZ2VkLCA1IGluc2VydGlvbnMoKyksIDAgZGVsZXRpb25zKC0pCgpkaWZmIC0tZ2l0IGEvZHJp
dmVycy9uZXQvZXRoZXJuZXQvaW50ZWwvZTEwMDBlL3BoeS5jIGIvZHJpdmVycy9uZXQvZXRoZXJu
ZXQvaW50ZWwvZTEwMDBlL3BoeS5jCmluZGV4IGY0ODdhN2YuLjk0NzZjOGYgMTAwNjQ0Ci0tLSBh
L2RyaXZlcnMvbmV0L2V0aGVybmV0L2ludGVsL2UxMDAwZS9waHkuYworKysgYi9kcml2ZXJzL25l
dC9ldGhlcm5ldC9pbnRlbC9lMTAwMGUvcGh5LmMKQEAgLTE3ODEsNiArMTc4MSwxMSBAQCBzMzIg
ZTEwMDBlX3BoeV9oYXNfbGlua19nZW5lcmljKHN0cnVjdCBlMTAwMF9odyAqaHcsIHUzMiBpdGVy
YXRpb25zLAogCXUxNiBwaHlfcmVnOwogCWludCBnb29kX3JlYWRzX3BoeV9zdGF0dXMgPSAwOwog
CisJLyogSWYgbG9vcGJhY2sgaXMgZW5hYmxlZCwgd2UgY2xhaW0gdGhlIGxpbmsgaXMgdXAgKi8K
KwlpZiAoKDAgPT0gZTFlX3JwaHkoaHcsIFBIWV9DT05UUk9MLCAmcGh5X3JlZykpCisJICAgICYm
IChwaHlfcmVnICYgTUlJX0NSX0xPT1BCQUNLKSkgeworCQkqc3VjY2VzcyA9IHRydWU7CisJCXJl
dHVybiAwOwogCX0KIAogCS8qCi0tIAoxLjcuMy4xCgoKLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tCkFs
bCB0aGUgZGF0YSBjb250aW51b3VzbHkgZ2VuZXJhdGVkIGluIHlvdXIgSVQgaW5mcmFzdHJ1Y3R1
cmUgCmNvbnRhaW5zIGEgZGVmaW5pdGl2ZSByZWNvcmQgb2YgY3VzdG9tZXJzLCBhcHBsaWNhdGlv
biBwZXJmb3JtYW5jZSwgCnNlY3VyaXR5IHRocmVhdHMsIGZyYXVkdWxlbnQgYWN0aXZpdHksIGFu
ZCBtb3JlLiBTcGx1bmsgdGFrZXMgdGhpcyAKZGF0YSBhbmQgbWFrZXMgc2Vuc2Ugb2YgaXQuIElU
IHNlbnNlLiBBbmQgY29tbW9uIHNlbnNlLgpodHRwOi8vcC5zZi5uZXQvc2Z1L3NwbHVuay1ub3Zk
MmQKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KRTEwMDAt
ZGV2ZWwgbWFpbGluZyBsaXN0CkUxMDAwLWRldmVsQGxpc3RzLnNvdXJjZWZvcmdlLm5ldApodHRw
czovL2xpc3RzLnNvdXJjZWZvcmdlLm5ldC9saXN0cy9saXN0aW5mby9lMTAwMC1kZXZlbApUbyBs
ZWFybiBtb3JlIGFib3V0IEludGVsJiMxNzQ7IEV0aGVybmV0LCB2aXNpdCBodHRwOi8vY29tbXVu
aXRpZXMuaW50ZWwuY29tL2NvbW11bml0eS93aXJlZAo=
