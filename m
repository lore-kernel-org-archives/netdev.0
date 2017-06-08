From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 28/44] sparc: remove arch specific dma_supported
 implementations
Date: Thu, 08 Jun 2017 10:24:05 -0400 (EDT)
Message-ID: <20170608.102405.746234218675861415.davem@davemloft.net>
References: <20170608132609.32662-1-hch@lst.de>
 <20170608132609.32662-29-hch@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: linux-mips@linux-mips.org, linux-samsung-soc@vger.kernel.org,
 linux-ia64@vger.kernel.org, linux-c6x-dev@linux-c6x.org,
 linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
 linux-hexagon@vger.kernel.org, linux-xtensa@linux-xtensa.org, x86@kernel.org,
 linux-tegra@vger.kernel.org, linux-kernel@vger.kernel.org,
 dri-devel@lists.freedesktop.org, dmaengine@vger.kernel.org,
 iommu@lists.linux-foundation.org, openrisc@lists.librecores.org,
 netdev@vger.kernel.org, sparclinux@vger.kernel.org,
 xen-devel@lists.xenproject.org, linuxppc-dev@lists.ozlabs.org,
 linux-arm-kernel@lists.infradead.org
To: hch@lst.de
Return-path: <dri-devel-bounces@lists.freedesktop.org>
In-Reply-To: <20170608132609.32662-29-hch@lst.de>
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

RnJvbTogQ2hyaXN0b3BoIEhlbGx3aWcgPGhjaEBsc3QuZGU+CkRhdGU6IFRodSwgIDggSnVuIDIw
MTcgMTU6MjU6NTMgKzAyMDAKCj4gVXN1YWxseSBkbWFfc3VwcG9ydGVkIGRlY2lzaW9ucyBhcmUg
ZG9uZSBieSB0aGUgZG1hX21hcF9vcHMgaW5zdGFuY2UuCj4gU3dpdGNoIHNwYXJjIHRvIHRoYXQg
bW9kZWwgYnkgcHJvdmlkaW5nIGEgLT5kbWFfc3VwcG9ydGVkIGluc3RhbmNlIGZvcgo+IHNidXMg
dGhhdCBhbHdheXMgcmV0dXJucyBmYWxzZSwgYW5kIGltcGxlbWVudGF0aW9ucyB0YWlsb3JlZCB0
byB0aGUgc3VuNHUKPiBhbmQgc3VuNHYgY2FzZXMgZm9yIHNwYXJjNjQsIGFuZCBsZWF2ZSBpdCB1
bmltcGxlbWVudGVkIGZvciBQQ0kgb24KPiBzcGFyYzMyLCB3aGljaCBtZWFucyBhbHdheXMgc3Vw
cG9ydGVkLgo+IAo+IFNpZ25lZC1vZmYtYnk6IENocmlzdG9waCBIZWxsd2lnIDxoY2hAbHN0LmRl
PgoKQWNrZWQtYnk6IERhdmlkIFMuIE1pbGxlciA8ZGF2ZW1AZGF2ZW1sb2Z0Lm5ldD4KX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KZHJpLWRldmVsIG1haWxp
bmcgbGlzdApkcmktZGV2ZWxAbGlzdHMuZnJlZWRlc2t0b3Aub3JnCmh0dHBzOi8vbGlzdHMuZnJl
ZWRlc2t0b3Aub3JnL21haWxtYW4vbGlzdGluZm8vZHJpLWRldmVsCg==
