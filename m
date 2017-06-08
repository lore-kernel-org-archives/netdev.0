From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 20/44] sparc: implement ->mapping_error
Date: Thu, 08 Jun 2017 10:24:29 -0400 (EDT)
Message-ID: <20170608.102429.1779556729256854546.davem@davemloft.net>
References: <20170608132609.32662-1-hch@lst.de>
 <20170608132609.32662-21-hch@lst.de>
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
In-Reply-To: <20170608132609.32662-21-hch@lst.de>
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
MTcgMTU6MjU6NDUgKzAyMDAKCj4gRE1BX0VSUk9SX0NPREUgaXMgZ29pbmcgdG8gZ28gYXdheSwg
c28gZG9uJ3QgcmVseSBvbiBpdC4KPiAKPiBTaWduZWQtb2ZmLWJ5OiBDaHJpc3RvcGggSGVsbHdp
ZyA8aGNoQGxzdC5kZT4KCkFja2VkLWJ5OiBEYXZpZCBTLiBNaWxsZXIgPGRhdmVtQGRhdmVtbG9m
dC5uZXQ+Cl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fCmRy
aS1kZXZlbCBtYWlsaW5nIGxpc3QKZHJpLWRldmVsQGxpc3RzLmZyZWVkZXNrdG9wLm9yZwpodHRw
czovL2xpc3RzLmZyZWVkZXNrdG9wLm9yZy9tYWlsbWFuL2xpc3RpbmZvL2RyaS1kZXZlbAo=
