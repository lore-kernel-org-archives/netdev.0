From: John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>
Subject: [PATCH 08/12] net: mediatek: fix threshold value
Date: Sun,  5 Jun 2016 08:33:01 +0200
Message-ID: <1465108385-38286-9-git-send-email-john@phrozen.org>
References: <1465108385-38286-1-git-send-email-john@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Sean Wang <keyhaede-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>, Felix Fietkau <nbd-Vt+b4OUoWG0@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1465108385-38286-1-git-send-email-john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-mediatek/>
List-Post: <mailto:linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-mediatek" <linux-mediatek-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

VGhlIGxvZ2ljIHRvIGNhbGN1bGF0ZSB0aGUgdGhyZXNob2xkIHZhbHVlIGZvciBzdG9wcGluZyB0
aGUgVFggcXVldWUgaXMKYmFkLiBDdXJyZW50bHkgaXQgd2lsbCBhbHdheXMgdXNlIDEvMiBvZiB0
aGUgcmluZ3Mgc2l6ZSwgd2hpY2ggaXMgd2F5IHRvbwptdWNoLiBTZXQgdGhlIHRocmVzaG9sZCB0
byBNQVhfU0tCX0ZSQUdTLiBUaGlzIG1ha2VzIHN1cmUgdGhhdCB0aGUgcXVldWUKaXMgc3RvcHBl
ZCB3aGVuIHRoZXJlIGlzIG5vdCBlbm91Z2ggcm9vbSB0byBhY2NlcHQgYW4gYWRkaXRpb25hbCBz
ZWdtZW50LsKgCgpTaWduZWQtb2ZmLWJ5OiBKb2huIENyaXNwaW4gPGpvaG5AcGhyb3plbi5vcmc+
Ci0tLQogZHJpdmVycy9uZXQvZXRoZXJuZXQvbWVkaWF0ZWsvbXRrX2V0aF9zb2MuYyB8ICAgIDMg
Ky0tCiAxIGZpbGUgY2hhbmdlZCwgMSBpbnNlcnRpb24oKyksIDIgZGVsZXRpb25zKC0pCgpkaWZm
IC0tZ2l0IGEvZHJpdmVycy9uZXQvZXRoZXJuZXQvbWVkaWF0ZWsvbXRrX2V0aF9zb2MuYyBiL2Ry
aXZlcnMvbmV0L2V0aGVybmV0L21lZGlhdGVrL210a19ldGhfc29jLmMKaW5kZXggOTNhZjRlMy4u
OGIyODllMSAxMDA2NDQKLS0tIGEvZHJpdmVycy9uZXQvZXRoZXJuZXQvbWVkaWF0ZWsvbXRrX2V0
aF9zb2MuYworKysgYi9kcml2ZXJzL25ldC9ldGhlcm5ldC9tZWRpYXRlay9tdGtfZXRoX3NvYy5j
CkBAIC0xMDEyLDggKzEwMTIsNyBAQCBzdGF0aWMgaW50IG10a190eF9hbGxvYyhzdHJ1Y3QgbXRr
X2V0aCAqZXRoKQogCWF0b21pY19zZXQoJnJpbmctPmZyZWVfY291bnQsIE1US19ETUFfU0laRSAt
IDIpOwogCXJpbmctPm5leHRfZnJlZSA9ICZyaW5nLT5kbWFbMF07CiAJcmluZy0+bGFzdF9mcmVl
ID0gJnJpbmctPmRtYVtNVEtfRE1BX1NJWkUgLSAyXTsKLQlyaW5nLT50aHJlc2ggPSBtYXgoKHVu
c2lnbmVkIGxvbmcpTVRLX0RNQV9TSVpFID4+IDIsCi0JCQkgICAgICBNQVhfU0tCX0ZSQUdTKTsK
KwlyaW5nLT50aHJlc2ggPSBNQVhfU0tCX0ZSQUdTOwogCiAJLyogbWFrZSBzdXJlIHRoYXQgYWxs
IGNoYW5nZXMgdG8gdGhlIGRtYSByaW5nIGFyZSBmbHVzaGVkIGJlZm9yZSB3ZQogCSAqIGNvbnRp
bnVlCi0tIAoxLjcuMTAuNAoKCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fCkxpbnV4LW1lZGlhdGVrIG1haWxpbmcgbGlzdApMaW51eC1tZWRpYXRla0BsaXN0
cy5pbmZyYWRlYWQub3JnCmh0dHA6Ly9saXN0cy5pbmZyYWRlYWQub3JnL21haWxtYW4vbGlzdGlu
Zm8vbGludXgtbWVkaWF0ZWsK
