From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 39/44] xen-swiotlb: remove
	xen_swiotlb_set_dma_mask
Date: Thu,  8 Jun 2017 15:26:04 +0200
Message-ID: <20170608132609.32662-40-hch@lst.de>
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

VGhpcyBqdXN0IGR1cGxpY2F0ZXMgdGhlIGdlbmVyaWMgaW1wbGVtZW50YXRpb24uCgpTaWduZWQt
b2ZmLWJ5OiBDaHJpc3RvcGggSGVsbHdpZyA8aGNoQGxzdC5kZT4KLS0tCiBkcml2ZXJzL3hlbi9z
d2lvdGxiLXhlbi5jIHwgMTIgLS0tLS0tLS0tLS0tCiAxIGZpbGUgY2hhbmdlZCwgMTIgZGVsZXRp
b25zKC0pCgpkaWZmIC0tZ2l0IGEvZHJpdmVycy94ZW4vc3dpb3RsYi14ZW4uYyBiL2RyaXZlcnMv
eGVuL3N3aW90bGIteGVuLmMKaW5kZXggYzNhMDRiMmQ3NTMyLi44MmZjNTRmOGViNzcgMTAwNjQ0
Ci0tLSBhL2RyaXZlcnMveGVuL3N3aW90bGIteGVuLmMKKysrIGIvZHJpdmVycy94ZW4vc3dpb3Rs
Yi14ZW4uYwpAQCAtNjYxLDE3ICs2NjEsNiBAQCB4ZW5fc3dpb3RsYl9kbWFfc3VwcG9ydGVkKHN0
cnVjdCBkZXZpY2UgKmh3ZGV2LCB1NjQgbWFzaykKIAlyZXR1cm4geGVuX3ZpcnRfdG9fYnVzKHhl
bl9pb190bGJfZW5kIC0gMSkgPD0gbWFzazsKIH0KIAotc3RhdGljIGludAoteGVuX3N3aW90bGJf
c2V0X2RtYV9tYXNrKHN0cnVjdCBkZXZpY2UgKmRldiwgdTY0IGRtYV9tYXNrKQotewotCWlmICgh
ZGV2LT5kbWFfbWFzayB8fCAheGVuX3N3aW90bGJfZG1hX3N1cHBvcnRlZChkZXYsIGRtYV9tYXNr
KSkKLQkJcmV0dXJuIC1FSU87Ci0KLQkqZGV2LT5kbWFfbWFzayA9IGRtYV9tYXNrOwotCi0JcmV0
dXJuIDA7Ci19Ci0KIC8qCiAgKiBDcmVhdGUgdXNlcnNwYWNlIG1hcHBpbmcgZm9yIHRoZSBETUEt
Y29oZXJlbnQgbWVtb3J5LgogICogVGhpcyBmdW5jdGlvbiBzaG91bGQgYmUgY2FsbGVkIHdpdGgg
dGhlIHBhZ2VzIGZyb20gdGhlIGN1cnJlbnQgZG9tYWluIG9ubHksCkBAIC03MzQsNyArNzIzLDYg
QEAgY29uc3Qgc3RydWN0IGRtYV9tYXBfb3BzIHhlbl9zd2lvdGxiX2RtYV9vcHMgPSB7CiAJLm1h
cF9wYWdlID0geGVuX3N3aW90bGJfbWFwX3BhZ2UsCiAJLnVubWFwX3BhZ2UgPSB4ZW5fc3dpb3Rs
Yl91bm1hcF9wYWdlLAogCS5kbWFfc3VwcG9ydGVkID0geGVuX3N3aW90bGJfZG1hX3N1cHBvcnRl
ZCwKLQkuc2V0X2RtYV9tYXNrID0geGVuX3N3aW90bGJfc2V0X2RtYV9tYXNrLAogCS5tbWFwID0g
eGVuX3N3aW90bGJfZG1hX21tYXAsCiAJLmdldF9zZ3RhYmxlID0geGVuX3N3aW90bGJfZ2V0X3Nn
dGFibGUsCiAJLm1hcHBpbmdfZXJyb3IJPSB4ZW5fc3dpb3RsYl9tYXBwaW5nX2Vycm9yLAotLSAK
Mi4xMS4wCgoKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18K
WGVuLWRldmVsIG1haWxpbmcgbGlzdApYZW4tZGV2ZWxAbGlzdHMueGVuLm9yZwpodHRwczovL2xp
c3RzLnhlbi5vcmcveGVuLWRldmVsCg==
