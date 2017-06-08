From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 33/44] openrisc: remove arch-specific
	dma_supported implementation
Date: Thu,  8 Jun 2017 15:25:58 +0200
Message-ID: <20170608132609.32662-34-hch@lst.de>
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

VGhpcyBpbXBsZW1lbnRhdGlvbiBpcyBzaW1wbHkgYm9ndXMgLSBoZXhhZ29uIG9ubHkgaGFzIGEg
c2ltcGxlCmRpcmVjdCBtYXBwZWQgRE1BIGltcGxlbWVudGF0aW9uIGFuZCB0aHVzIGRvZXNuJ3Qg
Y2FyZSBhYm91dCB0aGUKYWRkcmVzcy4KClNpZ25lZC1vZmYtYnk6IENocmlzdG9waCBIZWxsd2ln
IDxoY2hAbHN0LmRlPgotLS0KIGFyY2gvb3BlbnJpc2MvaW5jbHVkZS9hc20vZG1hLW1hcHBpbmcu
aCB8IDcgLS0tLS0tLQogMSBmaWxlIGNoYW5nZWQsIDcgZGVsZXRpb25zKC0pCgpkaWZmIC0tZ2l0
IGEvYXJjaC9vcGVucmlzYy9pbmNsdWRlL2FzbS9kbWEtbWFwcGluZy5oIGIvYXJjaC9vcGVucmlz
Yy9pbmNsdWRlL2FzbS9kbWEtbWFwcGluZy5oCmluZGV4IGE0ZWExMzljMmVmOS4uZjQxYmQzY2I3
NmQ5IDEwMDY0NAotLS0gYS9hcmNoL29wZW5yaXNjL2luY2x1ZGUvYXNtL2RtYS1tYXBwaW5nLmgK
KysrIGIvYXJjaC9vcGVucmlzYy9pbmNsdWRlL2FzbS9kbWEtbWFwcGluZy5oCkBAIC0zMywxMSAr
MzMsNCBAQCBzdGF0aWMgaW5saW5lIGNvbnN0IHN0cnVjdCBkbWFfbWFwX29wcyAqZ2V0X2FyY2hf
ZG1hX29wcyhzdHJ1Y3QgYnVzX3R5cGUgKmJ1cykKIAlyZXR1cm4gJm9yMWtfZG1hX21hcF9vcHM7
CiB9CiAKLSNkZWZpbmUgSEFWRV9BUkNIX0RNQV9TVVBQT1JURUQgMQotc3RhdGljIGlubGluZSBp
bnQgZG1hX3N1cHBvcnRlZChzdHJ1Y3QgZGV2aWNlICpkZXYsIHU2NCBkbWFfbWFzaykKLXsKLQkv
KiBTdXBwb3J0IDMyIGJpdCBETUEgbWFzayBleGNsdXNpdmVseSAqLwotCXJldHVybiBkbWFfbWFz
ayA9PSBETUFfQklUX01BU0soMzIpOwotfQotCiAjZW5kaWYJLyogX19BU01fT1BFTlJJU0NfRE1B
X01BUFBJTkdfSCAqLwotLSAKMi4xMS4wCgoKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX18KWGVuLWRldmVsIG1haWxpbmcgbGlzdApYZW4tZGV2ZWxAbGlzdHMu
eGVuLm9yZwpodHRwczovL2xpc3RzLnhlbi5vcmcveGVuLWRldmVsCg==
