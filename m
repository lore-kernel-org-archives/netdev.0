From: =?UTF-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>
Subject: [PATCHv2 1/2] remove redundant struct clk NULL checks
Date: Tue, 12 Jan 2016 16:17:55 +0100
Message-ID: <1452611876-451-2-git-send-email-LW@KARO-electronics.de>
References: <1452611876-451-1-git-send-email-LW@KARO-electronics.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
To: Andrew Lunn <andrew@lunn.ch>, "David S. Miller" <davem@davemloft.net>,
 Fabio Estevam <fabio.estevam@freescale.com>,
 Greg Ungerer <gerg@uclinux.org>, Kevin Hao <haokexin@gmail.com>,
 =?UTF-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>,
 Lucas Stach <l.stach@pengutronix.de>, Nimrod Andy <B38611@freescale.com>,
 Philippe Reynes <tremyfr@gmail.com>,
 Richard Cochran <richardcochran@gmail.com>,
 Russell King <rmk+kernel@arm.linux.org.uk>,
 Sascha Hauer <s.hauer@pengutronix.de>, Stefan Agner <stefan@agner.ch>,
 linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
 Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
 =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?= <u.kleine-koenig@pengutronix.de>,
 Ian Campbell <ijc+devicetree@hellion.org.uk>,
 Kumar Gala <galak@codeaurora.org>, Mark Rutland <mark.rutland@arm.com>,
 Pawel Moll <pawel.moll@arm.com>, Rob Herring <robh+dt@kernel.org>,
 Russell King <lin
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1452611876-451-1-git-send-email-LW@KARO-electronics.de>
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

TlVMTCBpcyBhIHZhbGlkIGFyZ3VtZW50IHRvIGNsa19lbmFibGUoKS9jbGtfZGlzYWJsZSgpLiBS
ZW1vdmUKcmVkdW5kYW50IGNoZWNrcyBiZWZvcmUgY2FsbGluZyB0aG9zZSBmdW5jdGlvbnMuCgpT
aWduZWQtb2ZmLWJ5OiBMb3RoYXIgV2HDn21hbm4gPExXQEtBUk8tZWxlY3Ryb25pY3MuZGU+Ci0t
LQogZHJpdmVycy9uZXQvZXRoZXJuZXQvZnJlZXNjYWxlL2ZlY19tYWluLmMgfCAyMyArKysrKysr
KystLS0tLS0tLS0tLS0tLQogMSBmaWxlIGNoYW5nZWQsIDkgaW5zZXJ0aW9ucygrKSwgMTQgZGVs
ZXRpb25zKC0pCgpkaWZmIC0tZ2l0IGEvZHJpdmVycy9uZXQvZXRoZXJuZXQvZnJlZXNjYWxlL2Zl
Y19tYWluLmMgYi9kcml2ZXJzL25ldC9ldGhlcm5ldC9mcmVlc2NhbGUvZmVjX21haW4uYwppbmRl
eCA1MDJkYTZmLi41OTJhN2E0IDEwMDY0NAotLS0gYS9kcml2ZXJzL25ldC9ldGhlcm5ldC9mcmVl
c2NhbGUvZmVjX21haW4uYworKysgYi9kcml2ZXJzL25ldC9ldGhlcm5ldC9mcmVlc2NhbGUvZmVj
X21haW4uYwpAQCAtMTg3NCwzNSArMTg3NCwzMCBAQCBzdGF0aWMgaW50IGZlY19lbmV0X2Nsa19l
bmFibGUoc3RydWN0IG5ldF9kZXZpY2UgKm5kZXYsIGJvb2wgZW5hYmxlKQogCQkJfQogCQkJbXV0
ZXhfdW5sb2NrKCZmZXAtPnB0cF9jbGtfbXV0ZXgpOwogCQl9Ci0JCWlmIChmZXAtPmNsa19yZWYp
IHsKLQkJCXJldCA9IGNsa19wcmVwYXJlX2VuYWJsZShmZXAtPmNsa19yZWYpOwotCQkJaWYgKHJl
dCkKLQkJCQlnb3RvIGZhaWxlZF9jbGtfcmVmOwotCQl9CisKKwkJcmV0ID0gY2xrX3ByZXBhcmVf
ZW5hYmxlKGZlcC0+Y2xrX3JlZik7CisJCWlmIChyZXQpCisJCQlnb3RvIGZhaWxlZF9jbGtfcmVm
OwogCX0gZWxzZSB7CiAJCWNsa19kaXNhYmxlX3VucHJlcGFyZShmZXAtPmNsa19haGIpOwotCQlp
ZiAoZmVwLT5jbGtfZW5ldF9vdXQpCi0JCQljbGtfZGlzYWJsZV91bnByZXBhcmUoZmVwLT5jbGtf
ZW5ldF9vdXQpOworCQljbGtfZGlzYWJsZV91bnByZXBhcmUoZmVwLT5jbGtfZW5ldF9vdXQpOwog
CQlpZiAoZmVwLT5jbGtfcHRwKSB7CiAJCQltdXRleF9sb2NrKCZmZXAtPnB0cF9jbGtfbXV0ZXgp
OwogCQkJY2xrX2Rpc2FibGVfdW5wcmVwYXJlKGZlcC0+Y2xrX3B0cCk7CiAJCQlmZXAtPnB0cF9j
bGtfb24gPSBmYWxzZTsKIAkJCW11dGV4X3VubG9jaygmZmVwLT5wdHBfY2xrX211dGV4KTsKIAkJ
fQotCQlpZiAoZmVwLT5jbGtfcmVmKQotCQkJY2xrX2Rpc2FibGVfdW5wcmVwYXJlKGZlcC0+Y2xr
X3JlZik7CisJCWNsa19kaXNhYmxlX3VucHJlcGFyZShmZXAtPmNsa19yZWYpOwogCX0KIAogCXJl
dHVybiAwOwogCiBmYWlsZWRfY2xrX3JlZjoKLQlpZiAoZmVwLT5jbGtfcmVmKQotCQljbGtfZGlz
YWJsZV91bnByZXBhcmUoZmVwLT5jbGtfcmVmKTsKKwljbGtfZGlzYWJsZV91bnByZXBhcmUoZmVw
LT5jbGtfcmVmKTsKIGZhaWxlZF9jbGtfcHRwOgotCWlmIChmZXAtPmNsa19lbmV0X291dCkKLQkJ
Y2xrX2Rpc2FibGVfdW5wcmVwYXJlKGZlcC0+Y2xrX2VuZXRfb3V0KTsKKwljbGtfZGlzYWJsZV91
bnByZXBhcmUoZmVwLT5jbGtfZW5ldF9vdXQpOwogZmFpbGVkX2Nsa19lbmV0X291dDoKLQkJY2xr
X2Rpc2FibGVfdW5wcmVwYXJlKGZlcC0+Y2xrX2FoYik7CisJY2xrX2Rpc2FibGVfdW5wcmVwYXJl
KGZlcC0+Y2xrX2FoYik7CiAKIAlyZXR1cm4gcmV0OwogfQotLSAKMi4xLjQKCgpfX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpsaW51eC1hcm0ta2VybmVsIG1h
aWxpbmcgbGlzdApsaW51eC1hcm0ta2VybmVsQGxpc3RzLmluZnJhZGVhZC5vcmcKaHR0cDovL2xp
c3RzLmluZnJhZGVhZC5vcmcvbWFpbG1hbi9saXN0aW5mby9saW51eC1hcm0ta2VybmVsCg==
