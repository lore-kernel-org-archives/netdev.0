From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 04/44] drm/exynos: don't use DMA_ERROR_CODE
Date: Fri, 16 Jun 2017 20:10:19 +0200
Message-ID: <20170616181059.19206-5-hch@lst.de>
References: <20170616181059.19206-1-hch@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: linux-kernel@vger.kernel.org
To: x86@kernel.org, linux-arm-kernel@lists.infradead.org,
 xen-devel@lists.xenproject.org, linux-c6x-dev@linux-c6x.org,
 linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org,
 linux-mips@linux-mips.org, openrisc@lists.librecores.org,
 linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
 linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
 linux-xtensa@linux-xtensa.org, dmaengine@vger.kernel.org,
 linux-tegra@vger.kernel.org, dri-devel@lists.freedesktop.org,
 linux-samsung-soc@vger.kernel.org, iommu@lists.linux-foundation.org,
 netdev@vger.kernel.org
Return-path: <dri-devel-bounces@lists.freedesktop.org>
In-Reply-To: <20170616181059.19206-1-hch@lst.de>
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

RE1BX0VSUk9SX0NPREUgYWxyZWFkeSBpc24ndCBhIHZhbGlkIEFQSSB0byB1c2VyIGZvciBkcml2
ZXJzIGFuZCB3aWxsCmdvIGF3YXkgc29vbi4gIGV4eW5vc19kcm1fZmJfZG1hX2FkZHIgdXNlcyBp
dCBhIGFuIGVycm9yIHJldHVybiB3aGVuCnRoZSBwYXNzZWQgaW4gaW5kZXggaXMgaW52YWxpZCwg
YnV0IHRoZSBjYWxsZXJzIG5ldmVyIGNoZWNrIGZvciBpdApidXQgaW5zdGVhZCBwYXNzIHRoZSBh
ZGRyZXNzIHN0cmFpZ2h0IHRvIHRoZSBoYXJkd2FyZS4KCkFkZCBhIFdBUk5fT04gaW5zdGVhZCBh
bmQganVzdCByZXR1cm4gMC4KClNpZ25lZC1vZmYtYnk6IENocmlzdG9waCBIZWxsd2lnIDxoY2hA
bHN0LmRlPgotLS0KIGRyaXZlcnMvZ3B1L2RybS9leHlub3MvZXh5bm9zX2RybV9mYi5jIHwgNCAr
Ky0tCiAxIGZpbGUgY2hhbmdlZCwgMiBpbnNlcnRpb25zKCspLCAyIGRlbGV0aW9ucygtKQoKZGlm
ZiAtLWdpdCBhL2RyaXZlcnMvZ3B1L2RybS9leHlub3MvZXh5bm9zX2RybV9mYi5jIGIvZHJpdmVy
cy9ncHUvZHJtL2V4eW5vcy9leHlub3NfZHJtX2ZiLmMKaW5kZXggYzc3YTVhY2VkODFhLi5kNDhm
ZDdjOTE4ZjggMTAwNjQ0Ci0tLSBhL2RyaXZlcnMvZ3B1L2RybS9leHlub3MvZXh5bm9zX2RybV9m
Yi5jCisrKyBiL2RyaXZlcnMvZ3B1L2RybS9leHlub3MvZXh5bm9zX2RybV9mYi5jCkBAIC0xODEs
OCArMTgxLDggQEAgZG1hX2FkZHJfdCBleHlub3NfZHJtX2ZiX2RtYV9hZGRyKHN0cnVjdCBkcm1f
ZnJhbWVidWZmZXIgKmZiLCBpbnQgaW5kZXgpCiB7CiAJc3RydWN0IGV4eW5vc19kcm1fZmIgKmV4
eW5vc19mYiA9IHRvX2V4eW5vc19mYihmYik7CiAKLQlpZiAoaW5kZXggPj0gTUFYX0ZCX0JVRkZF
UikKLQkJcmV0dXJuIERNQV9FUlJPUl9DT0RFOworCWlmIChXQVJOX09OX09OQ0UoaW5kZXggPj0g
TUFYX0ZCX0JVRkZFUikpCisJCXJldHVybiAwOwogCiAJcmV0dXJuIGV4eW5vc19mYi0+ZG1hX2Fk
ZHJbaW5kZXhdOwogfQotLSAKMi4xMS4wCgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fXwpkcmktZGV2ZWwgbWFpbGluZyBsaXN0CmRyaS1kZXZlbEBsaXN0cy5m
cmVlZGVza3RvcC5vcmcKaHR0cHM6Ly9saXN0cy5mcmVlZGVza3RvcC5vcmcvbWFpbG1hbi9saXN0
aW5mby9kcmktZGV2ZWwK
