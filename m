From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 05/14] isdn: isdnloop: suppress a gcc-7 warning
Date: Fri, 14 Jul 2017 11:25:17 +0200
Message-ID: <20170714092540.1217397-6-arnd@arndb.de>
References: <20170714092540.1217397-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Arnd Bergmann <arnd@arndb.de>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 dri-devel@lists.freedesktop.org, linux-ide@vger.kernel.org,
 netdev@vger.kernel.org, Tejun Heo <tj@kernel.org>, akpm@linux-foundation.org,
 Linus Torvalds <torvalds@linux-foundation.org>,
 Guenter Roeck <linux@roeck-us.net>, linux-media@vger.kernel.org
To: linux-kernel@vger.kernel.org, Karsten Keil <isdn@linux-pingi.de>,
 "David S. Miller" <davem@davemloft.net>
Return-path: <dri-devel-bounces@lists.freedesktop.org>
In-Reply-To: <20170714092540.1217397-1-arnd@arndb.de>
List-Unsubscribe: <https://lists.freedesktop.org/mailman/options/dri-devel>,
 <mailto:dri-devel-request@lists.freedesktop.org?subject=unsubscribe>
List-Archive: <https://lists.freedesktop.org/archives/dri-devel>
List-Post: <mailto:dri-devel@lists.freedesktop.org>
List-Help: <mailto:dri-devel-request@lists.freedesktop.org?subject=help>
List-Subscribe: <https://lists.freedesktop.org/mailman/listinfo/dri-devel>,
 <mailto:dri-devel-request@lists.freedesktop.org?subject=subscribe>
Errors-To: dri-devel-bounces@lists.freedesktop.org
Sender: "dri-devel" <dri-devel-bounces@lists.freedesktop.org>
List-Id: netdev.vger.kernel.org

V2UgdGVzdCB3aGV0aGVyIGEgYml0IGlzIHNldCBpbiBhIG1hc2sgaGVyZSwgd2hpY2ggaXMgY29y
cmVjdApidXQgZ2NjIHdhcm5zIGFib3V0IGl0IGFzIGl0IHRoaW5rcyBpdCBtaWdodCBiZSBjb25m
dXNpbmc6Cgpkcml2ZXJzL2lzZG4vaXNkbmxvb3AvaXNkbmxvb3AuYzo0MTI6Mzc6IGVycm9yOiA/
OiB1c2luZyBpbnRlZ2VyIGNvbnN0YW50cyBpbiBib29sZWFuIGNvbnRleHQsIHRoZSBleHByZXNz
aW9uIHdpbGwgYWx3YXlzIGV2YWx1YXRlIHRvICd0cnVlJyBbLVdlcnJvcj1pbnQtaW4tYm9vbC1j
b250ZXh0XQoKVGhpcyByZXBsYWNlcyB0aGUgbmVnYXRpb24gb2YgYW4gaW50ZWdlciB3aXRoIGFu
IGVxdWl2YWxlbnQKY29tcGFyaXNvbiB0byB6ZXJvLCB3aGljaCBnZXRzIHJpZCBvZiB0aGUgd2Fy
bmluZy4KClNpZ25lZC1vZmYtYnk6IEFybmQgQmVyZ21hbm4gPGFybmRAYXJuZGIuZGU+Ci0tLQog
ZHJpdmVycy9pc2RuL2lzZG5sb29wL2lzZG5sb29wLmMgfCAyICstCiAxIGZpbGUgY2hhbmdlZCwg
MSBpbnNlcnRpb24oKyksIDEgZGVsZXRpb24oLSkKCmRpZmYgLS1naXQgYS9kcml2ZXJzL2lzZG4v
aXNkbmxvb3AvaXNkbmxvb3AuYyBiL2RyaXZlcnMvaXNkbi9pc2RubG9vcC9pc2RubG9vcC5jCmlu
ZGV4IDZmZmQxMzQ2NmI4Yy4uNTc5MjkyOGI5NDRkIDEwMDY0NAotLS0gYS9kcml2ZXJzL2lzZG4v
aXNkbmxvb3AvaXNkbmxvb3AuYworKysgYi9kcml2ZXJzL2lzZG4vaXNkbmxvb3AvaXNkbmxvb3Au
YwpAQCAtNDA5LDcgKzQwOSw3IEBAIGlzZG5sb29wX3NlbmRidWYoaW50IGNoYW5uZWwsIHN0cnVj
dCBza19idWZmICpza2IsIGlzZG5sb29wX2NhcmQgKmNhcmQpCiAJCXJldHVybiAtRUlOVkFMOwog
CX0KIAlpZiAobGVuKSB7Ci0JCWlmICghKGNhcmQtPmZsYWdzICYgKGNoYW5uZWwpID8gSVNETkxP
T1BfRkxBR1NfQjJBQ1RJVkUgOiBJU0ROTE9PUF9GTEFHU19CMUFDVElWRSkpCisJCWlmICgoY2Fy
ZC0+ZmxhZ3MgJiAoY2hhbm5lbCkgPyBJU0ROTE9PUF9GTEFHU19CMkFDVElWRSA6IElTRE5MT09Q
X0ZMQUdTX0IxQUNUSVZFKSA9PSAwKQogCQkJcmV0dXJuIDA7CiAJCWlmIChjYXJkLT5zbmRjb3Vu
dFtjaGFubmVsXSA+IElTRE5MT09QX01BWF9TUVVFVUUpCiAJCQlyZXR1cm4gMDsKLS0gCjIuOS4w
CgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpkcmktZGV2
ZWwgbWFpbGluZyBsaXN0CmRyaS1kZXZlbEBsaXN0cy5mcmVlZGVza3RvcC5vcmcKaHR0cHM6Ly9s
aXN0cy5mcmVlZGVza3RvcC5vcmcvbWFpbG1hbi9saXN0aW5mby9kcmktZGV2ZWwK
