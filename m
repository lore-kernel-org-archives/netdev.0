From: =?UTF-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>
Subject: [PATCHv2 4/6] net: fec: use swab32s() instead of cpu_to_be32()
Date: Tue, 28 Oct 2014 12:01:42 +0100
Message-ID: <1414494104-27943-5-git-send-email-LW@KARO-electronics.de>
References: <1414494104-27943-1-git-send-email-LW@KARO-electronics.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Fabio Estevam <fabio.estevam@freescale.com>,
 Frank Li <Frank.Li@freescale.com>, linux-kernel@vger.kernel.org,
 Russell King <rmk+kernel@arm.linux.org.uk>,
 "David S. Miller" <davem@davemloft.net>, linux-arm-kernel@lists.infradead.org,
 =?UTF-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>
To: netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1414494104-27943-1-git-send-email-LW@KARO-electronics.de>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

d2hlbiBzd2FwX2J1ZmZlcigpIGlzIGJlaW5nIGNhbGxlZCwgd2Uga25vdyBmb3Igc3VyZSwgdGhh
dCB3ZSBuZWVkIHRvCmJ5dGUgc3dhcCB0aGUgZGF0YS4gQWxzbyB0aGlzIGZ1bmN0aW9uIGlzIGNh
bGxlZCBmb3Igc3dhcHBpbmcgZGF0YSBpbgpib3RoIGRpcmVjdGlvbnMuIFRodXMgY3B1X3RvX2Jl
MzIoKSBpcyBzZW1hbnRpY2FsbHkgbm90IGNvcnJlY3QgZm9yCmFsbCB1c2UgY2FzZXMuIFVzZSBz
d2FiMzJzKCkgdG8gcmVmbGVjdCB0aGlzLgoKU2lnbmVkLW9mZi1ieTogTG90aGFyIFdhw59tYW5u
IDxMV0BLQVJPLWVsZWN0cm9uaWNzLmRlPgotLS0KIGRyaXZlcnMvbmV0L2V0aGVybmV0L2ZyZWVz
Y2FsZS9mZWNfbWFpbi5jIHwgICAgMiArLQogMSBmaWxlIGNoYW5nZWQsIDEgaW5zZXJ0aW9uKCsp
LCAxIGRlbGV0aW9uKC0pCgpkaWZmIC0tZ2l0IGEvZHJpdmVycy9uZXQvZXRoZXJuZXQvZnJlZXNj
YWxlL2ZlY19tYWluLmMgYi9kcml2ZXJzL25ldC9ldGhlcm5ldC9mcmVlc2NhbGUvZmVjX21haW4u
YwppbmRleCAzMjNhZTJlLi4zYTEwM2U5IDEwMDY0NAotLS0gYS9kcml2ZXJzL25ldC9ldGhlcm5l
dC9mcmVlc2NhbGUvZmVjX21haW4uYworKysgYi9kcml2ZXJzL25ldC9ldGhlcm5ldC9mcmVlc2Nh
bGUvZmVjX21haW4uYwpAQCAtMzM0LDcgKzMzNCw3IEBAIHN0YXRpYyB2b2lkICpzd2FwX2J1ZmZl
cih2b2lkICpidWZhZGRyLCBpbnQgbGVuKQogCXVuc2lnbmVkIGludCAqYnVmID0gYnVmYWRkcjsK
IAogCWZvciAoaSA9IDA7IGkgPCBESVZfUk9VTkRfVVAobGVuLCA0KTsgaSsrLCBidWYrKykKLQkJ
KmJ1ZiA9IGNwdV90b19iZTMyKCpidWYpOworCQlzd2FiMzJzKGJ1Zik7CiAKIAlyZXR1cm4gYnVm
YWRkcjsKIH0KLS0gCjEuNy4xMC40CgoKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX18KbGludXgtYXJtLWtlcm5lbCBtYWlsaW5nIGxpc3QKbGludXgtYXJtLWtl
cm5lbEBsaXN0cy5pbmZyYWRlYWQub3JnCmh0dHA6Ly9saXN0cy5pbmZyYWRlYWQub3JnL21haWxt
YW4vbGlzdGluZm8vbGludXgtYXJtLWtlcm5lbAo=
