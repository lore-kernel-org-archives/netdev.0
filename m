From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 29/44] dma-noop: remove dma_supported and
	mapping_error methods
Date: Thu,  8 Jun 2017 15:25:54 +0200
Message-ID: <20170608132609.32662-30-hch@lst.de>
References: <20170608132609.32662-1-hch@lst.de>
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
In-Reply-To: <20170608132609.32662-1-hch@lst.de>
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
Ci0tLQogbGliL2RtYS1ub29wLmMgfCAxMiAtLS0tLS0tLS0tLS0KIDEgZmlsZSBjaGFuZ2VkLCAx
MiBkZWxldGlvbnMoLSkKCmRpZmYgLS1naXQgYS9saWIvZG1hLW5vb3AuYyBiL2xpYi9kbWEtbm9v
cC5jCmluZGV4IGRlMjZjOGI2OGYzNC4uNjQzYTA3NGYxMzlkIDEwMDY0NAotLS0gYS9saWIvZG1h
LW5vb3AuYworKysgYi9saWIvZG1hLW5vb3AuYwpAQCAtNTQsMjMgKzU0LDExIEBAIHN0YXRpYyBp
bnQgZG1hX25vb3BfbWFwX3NnKHN0cnVjdCBkZXZpY2UgKmRldiwgc3RydWN0IHNjYXR0ZXJsaXN0
ICpzZ2wsIGludCBuZW50CiAJcmV0dXJuIG5lbnRzOwogfQogCi1zdGF0aWMgaW50IGRtYV9ub29w
X21hcHBpbmdfZXJyb3Ioc3RydWN0IGRldmljZSAqZGV2LCBkbWFfYWRkcl90IGRtYV9hZGRyKQot
ewotCXJldHVybiAwOwotfQotCi1zdGF0aWMgaW50IGRtYV9ub29wX3N1cHBvcnRlZChzdHJ1Y3Qg
ZGV2aWNlICpkZXYsIHU2NCBtYXNrKQotewotCXJldHVybiAxOwotfQotCiBjb25zdCBzdHJ1Y3Qg
ZG1hX21hcF9vcHMgZG1hX25vb3Bfb3BzID0gewogCS5hbGxvYwkJCT0gZG1hX25vb3BfYWxsb2Ms
CiAJLmZyZWUJCQk9IGRtYV9ub29wX2ZyZWUsCiAJLm1hcF9wYWdlCQk9IGRtYV9ub29wX21hcF9w
YWdlLAogCS5tYXBfc2cJCQk9IGRtYV9ub29wX21hcF9zZywKLQkubWFwcGluZ19lcnJvcgkJPSBk
bWFfbm9vcF9tYXBwaW5nX2Vycm9yLAotCS5kbWFfc3VwcG9ydGVkCQk9IGRtYV9ub29wX3N1cHBv
cnRlZCwKIH07CiAKIEVYUE9SVF9TWU1CT0woZG1hX25vb3Bfb3BzKTsKLS0gCjIuMTEuMAoKCl9f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fClhlbi1kZXZlbCBt
YWlsaW5nIGxpc3QKWGVuLWRldmVsQGxpc3RzLnhlbi5vcmcKaHR0cHM6Ly9saXN0cy54ZW4ub3Jn
L3hlbi1kZXZlbAo=
