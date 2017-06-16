From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 30/44] dma-virt: remove dma_supported and
	mapping_error methods
Date: Fri, 16 Jun 2017 20:10:45 +0200
Message-ID: <20170616181059.19206-31-hch@lst.de>
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
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <20170616181059.19206-1-hch@lst.de>
List-Unsubscribe: <https://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
 <mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <https://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
 <mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Errors-To: xen-devel-bounces@lists.xen.org
Sender: "Xen-devel" <xen-devel-bounces@lists.xen.org>
List-Id: netdev.vger.kernel.org

VGhlc2UganVzdCBkdXBsaWNhdGUgdGhlIGRlZmF1bHQgYmVoYXZpb3IgaWYgbm8gbWV0aG9kIGlz
IHByb3ZpZGVkLgoKU2lnbmVkLW9mZi1ieTogQ2hyaXN0b3BoIEhlbGx3aWcgPGhjaEBsc3QuZGU+
Ci0tLQogbGliL2RtYS12aXJ0LmMgfCAxMiAtLS0tLS0tLS0tLS0KIDEgZmlsZSBjaGFuZ2VkLCAx
MiBkZWxldGlvbnMoLSkKCmRpZmYgLS1naXQgYS9saWIvZG1hLXZpcnQuYyBiL2xpYi9kbWEtdmly
dC5jCmluZGV4IGRjZDRkZjFmNzE3NC4uNWM0ZjExMzI5NzIxIDEwMDY0NAotLS0gYS9saWIvZG1h
LXZpcnQuYworKysgYi9saWIvZG1hLXZpcnQuYwpAQCAtNTEsMjIgKzUxLDEwIEBAIHN0YXRpYyBp
bnQgZG1hX3ZpcnRfbWFwX3NnKHN0cnVjdCBkZXZpY2UgKmRldiwgc3RydWN0IHNjYXR0ZXJsaXN0
ICpzZ2wsCiAJcmV0dXJuIG5lbnRzOwogfQogCi1zdGF0aWMgaW50IGRtYV92aXJ0X21hcHBpbmdf
ZXJyb3Ioc3RydWN0IGRldmljZSAqZGV2LCBkbWFfYWRkcl90IGRtYV9hZGRyKQotewotCXJldHVy
biBmYWxzZTsKLX0KLQotc3RhdGljIGludCBkbWFfdmlydF9zdXBwb3J0ZWQoc3RydWN0IGRldmlj
ZSAqZGV2LCB1NjQgbWFzaykKLXsKLQlyZXR1cm4gdHJ1ZTsKLX0KLQogY29uc3Qgc3RydWN0IGRt
YV9tYXBfb3BzIGRtYV92aXJ0X29wcyA9IHsKIAkuYWxsb2MJCQk9IGRtYV92aXJ0X2FsbG9jLAog
CS5mcmVlCQkJPSBkbWFfdmlydF9mcmVlLAogCS5tYXBfcGFnZQkJPSBkbWFfdmlydF9tYXBfcGFn
ZSwKIAkubWFwX3NnCQkJPSBkbWFfdmlydF9tYXBfc2csCi0JLm1hcHBpbmdfZXJyb3IJCT0gZG1h
X3ZpcnRfbWFwcGluZ19lcnJvciwKLQkuZG1hX3N1cHBvcnRlZAkJPSBkbWFfdmlydF9zdXBwb3J0
ZWQsCiB9OwogRVhQT1JUX1NZTUJPTChkbWFfdmlydF9vcHMpOwotLSAKMi4xMS4wCgoKX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KWGVuLWRldmVsIG1haWxp
bmcgbGlzdApYZW4tZGV2ZWxAbGlzdHMueGVuLm9yZwpodHRwczovL2xpc3RzLnhlbi5vcmcveGVu
LWRldmVsCg==
