From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: Re: new dma-mapping tree,
 was Re: clean up and modularize arch dma_mapping interface V2
Date: Wed, 21 Jun 2017 15:32:39 +0200
Message-ID: <5425587c-73e8-e24a-86a3-8a65a7791dcb@samsung.com>
References: <20170616181059.19206-1-hch@lst.de> <20170620124140.GA27163@lst.de>
 <20170620230400.1a5ae889@canb.auug.org.au>
 <CGME20170620131628epcas1p4f21d821bd414cba7e2d49abcbe414365@epcas1p4.samsung.com>
 <20170620131623.GB30769@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; Format="flowed"
Content-Transfer-Encoding: base64
Cc: linux-mips@linux-mips.org, linux-ia64@vger.kernel.org,
 linux-sh@vger.kernel.org, dri-devel@lists.freedesktop.org,
 sparclinux@vger.kernel.org, linux-s390@vger.kernel.org,
 linux-samsung-soc@vger.kernel.org, linux-c6x-dev@linux-c6x.org,
 linux-hexagon@vger.kernel.org, x86@kernel.org,
 iommu@lists.linux-foundation.org,
 Linus Torvalds <torvalds@linux-foundation.org>, xen-devel@lists.xenproject.org,
 linux-xtensa@linux-xtensa.org, openrisc@lists.librecores.org,
 linux-tegra@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 Kyungmin Park <kyungmin.park@samsung.com>, dmaengine@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org
To: Christoph Hellwig <hch@lst.de>, Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <dri-devel-bounces@lists.freedesktop.org>
In-reply-to: <20170620131623.GB30769@lst.de>
Content-language: en-US
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

SGkgQ2hyaXN0b3BoLAoKT24gMjAxNy0wNi0yMCAxNToxNiwgQ2hyaXN0b3BoIEhlbGx3aWcgd3Jv
dGU6Cj4gT24gVHVlLCBKdW4gMjAsIDIwMTcgYXQgMTE6MDQ6MDBQTSArMTAwMCwgU3RlcGhlbiBS
b3Rod2VsbCB3cm90ZToKPj4gZ2l0Oi8vZ2l0LmxpbmFyby5vcmcvcGVvcGxlL21zenlwcm93c2tp
L2xpbnV4LWRtYS1tYXBwaW5nLmdpdCNkbWEtbWFwcGluZy1uZXh0Cj4+Cj4+IENvbnRhY3RzOiBN
YXJlayBTenlwcm93c2tpIGFuZCBLeXVuZ21pbiBQYXJrIChjYydkKQo+Pgo+PiBJIGhhdmUgY2Fs
bGVkIHlvdXIgdHJlZSBkbWEtbWFwcGluZy1oY2ggZm9yIG5vdy4gIFRoZSBvdGhlciB0cmVlIGhh
cwo+PiBub3QgYmVlbiB1cGRhdGVkIHNpbmNlIDQuOS1yYzEgYW5kIEkgYW0gbm90IHN1cmUgaG93
IGdlbmVyYWwgaXQgaXMuCj4+IE1hcmVrLCBLeXVuZ21pbiwgYW55IGNvbW1lbnRzPwo+IEknZCBi
ZSBoYXBweSB0byBqb2luIGVmZm9ydHMgLSBjby1tYWludGFpbmVycyBhbmQgcmV2aWVycyBhcmUg
YWx3YXlzCj4gd2VsY29tZS4KCkkgZGlkIHNvbWUgZG1hLW1hcHBpbmcgdW5pZmljYXRpb24gd29y
a3MgaW4gdGhlIHBhc3QgYW5kIG15IHRyZWUgaW4gCmxpbnV4LW5leHQKd2FzIGEgc2lkZSBlZmZl
Y3Qgb2YgdGhhdC4gSSB0aGluayB0aGF0IGZvciBub3cgaXQgY2FuIGJlIGRyb3BwZWQgaW4gCmZh
dm9yIG9mCkNocmlzdG9waCdzIHRyZWUuIEkgY2FuIGFsc28gZG8gc29tZSByZXZpZXcgYW5kIGhl
bHAgaW4gbWFpbnRhaW5lcnMgd29yayBpZgpuZWVkZWQsIGFsdGhvdWdoIEkgd2FzIHJlY2VudGx5
IGJ1c3kgd2l0aCBvdGhlciBzdHVmZi4KCkNocmlzdG9waDogQ291bGQgeW91IGFkZCBtZSB0byB5
b3VyIE1BSU5UQUlORVJTIHBhdGNoLCBzbyBmdXJ0aGVyIApkbWEtbWFwcGluZwpyZWxhdGVkIHBh
dGNoZXMgaG9wZWZ1bGx5IHdpbGwgYmUgYWxzbyBDQzogdG8gbWU/CgpCZXN0IHJlZ2FyZHMKLS0g
Ck1hcmVrIFN6eXByb3dza2ksIFBoRApTYW1zdW5nIFImRCBJbnN0aXR1dGUgUG9sYW5kCgpfX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpkcmktZGV2ZWwgbWFp
bGluZyBsaXN0CmRyaS1kZXZlbEBsaXN0cy5mcmVlZGVza3RvcC5vcmcKaHR0cHM6Ly9saXN0cy5m
cmVlZGVza3RvcC5vcmcvbWFpbG1hbi9saXN0aW5mby9kcmktZGV2ZWwK
