From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur@brendeland.net>
Subject: [RFC virtio-next 2/4] include/vring.h: Add support for reversed
	vritio rings.
Date: Wed, 31 Oct 2012 23:46:52 +0100
Message-ID: <1351723614-4145-3-git-send-email-sjur@brendeland.net>
References: <1351723614-4145-1-git-send-email-sjur@brendeland.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	Linus Walleij <linus.walleij@linaro.org>,
	dmitry.tarnyagin@stericsson.com, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, sjur@brendeland.net,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1351723614-4145-1-git-send-email-sjur@brendeland.net>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

RnJvbTogU2p1ciBCcsOmbmRlbGFuZCA8c2p1ci5icmFuZGVsYW5kQHN0ZXJpY3Nzb24uY29tPgoK
QWRkIGxhc3QgYXZpbGFibGUgaW5kZXggdG8gdGhlIHZyaW5nX3ZpcnRxdWV1ZSBzdHJ1Y3R1cmUs
CnRoaXMgaXMgZG9uZSB0byBwcmVwYXJlIGZvciBpbXBsZW1lbnRhdGlvbiBvZiB0aGUgcmV2ZXJz
ZWQgdnJpbmcuCgpTaWduZWQtb2ZmLWJ5OiBTanVyIEJyw6ZuZGVsYW5kIDxzanVyLmJyYW5kZWxh
bmRAc3Rlcmljc3Nvbi5jb20+Ci0tLQogZHJpdmVycy92aXJ0aW8vdnJpbmcuaCB8ICAgIDMgKysr
CiAxIGZpbGUgY2hhbmdlZCwgMyBpbnNlcnRpb25zKCspCgpkaWZmIC0tZ2l0IGEvZHJpdmVycy92
aXJ0aW8vdnJpbmcuaCBiL2RyaXZlcnMvdmlydGlvL3ZyaW5nLmgKaW5kZXggYjk5N2ZjMy4uM2I1
Mzk2MSAxMDA2NDQKLS0tIGEvZHJpdmVycy92aXJ0aW8vdnJpbmcuaAorKysgYi9kcml2ZXJzL3Zp
cnRpby92cmluZy5oCkBAIC01MSw2ICs1MSw5IEBAIHN0cnVjdCB2cmluZ192aXJ0cXVldWUKIAkv
KiBMYXN0IHVzZWQgaW5kZXggd2UndmUgc2Vlbi4gKi8KIAl1MTYgbGFzdF91c2VkX2lkeDsKIAor
CS8qIExhc3QgYXZhaWwgaW5kZXggc2Vlbi4gTk9URTogT25seSB1c2VkIGZvciByZXZlcnNlZCBy
aW5ncy4qLworCXUxNiBsYXN0X2F2YWlsX2lkeDsKKwogCS8qIEhvdyB0byBub3RpZnkgb3RoZXIg
c2lkZS4gRklYTUU6IGNvbW1vbmFsaXplIGhjYWxscyEgKi8KIAl2b2lkICgqbm90aWZ5KShzdHJ1
Y3QgdmlydHF1ZXVlICp2cSk7CiAKLS0gCjEuNy45LjUKCl9fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fClZpcnR1YWxpemF0aW9uIG1haWxpbmcgbGlzdApWaXJ0
dWFsaXphdGlvbkBsaXN0cy5saW51eC1mb3VuZGF0aW9uLm9yZwpodHRwczovL2xpc3RzLmxpbnV4
Zm91bmRhdGlvbi5vcmcvbWFpbG1hbi9saXN0aW5mby92aXJ0dWFsaXphdGlvbg==
