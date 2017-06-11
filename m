From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH 07/44] xen-swiotlb: consolidate xen_swiotlb_dma_ops
Date: Sat, 10 Jun 2017 22:36:44 -0400
Message-ID: <20170611023644.GE30966@char.us.oracle.com>
References: <20170608132609.32662-1-hch@lst.de>
 <20170608132609.32662-8-hch@lst.de>
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
To: Christoph Hellwig <hch@lst.de>
Return-path: <dri-devel-bounces@lists.freedesktop.org>
Content-Disposition: inline
In-Reply-To: <20170608132609.32662-8-hch@lst.de>
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

T24gVGh1LCBKdW4gMDgsIDIwMTcgYXQgMDM6MjU6MzJQTSArMDIwMCwgQ2hyaXN0b3BoIEhlbGx3
aWcgd3JvdGU6Cj4gQVJNIGFuZCB4ODYgaGFkIGR1cGxpY2F0ZWQgdmVyc2lvbnMgb2YgdGhlIGRt
YV9vcHMgc3RydWN0dXJlLCB0aGUKPiBvbmx5IGRpZmZlcmVuY2UgaXMgdGhhdCB4ODYgaGFzbid0
IHdpcmVkIHVwIHRoZSBzZXRfZG1hX21hc2ssCj4gbW1hcCwgYW5kIGdldF9zZ3RhYmxlIG9wcyB5
ZXQuICBPbiB4ODYgYWxsIG9mIHRoZW0gYXJlIGlkZW50aWNhbAo+IHRvIHRoZSBnZW5lcmljIHZl
cnNpb24sIHNvIHRoZXkgYXJlbid0IG5lZWRlZCBidXQgaGFybWxlc3MuCj4gCj4gQWxsIHRoZSBz
eW1ib2xzIHVzZWQgb25seSBmb3IgeGVuX3N3aW90bGJfZG1hX29wcyBjYW4gbm93IGJlIG1hcmtl
ZAo+IHN0YXRpYyBhcyB3ZWxsLgo+IAo+IFNpZ25lZC1vZmYtYnk6IENocmlzdG9waCBIZWxsd2ln
IDxoY2hAbHN0LmRlPgo+IC0tLQo+ICBhcmNoL2FybS94ZW4vbW0uYyAgICAgICAgICAgICAgfCAx
NyAtLS0tLS0tLQo+ICBhcmNoL3g4Ni94ZW4vcGNpLXN3aW90bGIteGVuLmMgfCAxNCAtLS0tLS0t
Cj4gIGRyaXZlcnMveGVuL3N3aW90bGIteGVuLmMgICAgICB8IDkzICsrKysrKysrKysrKysrKysr
KysrKystLS0tLS0tLS0tLS0tLS0tLS0tLQo+ICBpbmNsdWRlL3hlbi9zd2lvdGxiLXhlbi5oICAg
ICAgfCA2MiArLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tCj4gIDQgZmlsZXMgY2hhbmdlZCwg
NDkgaW5zZXJ0aW9ucygrKSwgMTM3IGRlbGV0aW9ucygtKQoKWWVlZXkhCgpSZXZpZXdlZC1ieTog
S29ucmFkIFJ6ZXN6dXRlayBXaWxrIDxrb25yYWQud2lsa0BvcmFjbGUuY29tPgpfX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpkcmktZGV2ZWwgbWFpbGluZyBs
aXN0CmRyaS1kZXZlbEBsaXN0cy5mcmVlZGVza3RvcC5vcmcKaHR0cHM6Ly9saXN0cy5mcmVlZGVz
a3RvcC5vcmcvbWFpbG1hbi9saXN0aW5mby9kcmktZGV2ZWwK
