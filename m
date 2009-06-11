From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ixgbe: fix mismatched dma map/unmap size
Date: Thu, 11 Jun 2009 03:20:24 -0700 (PDT)
Message-ID: <20090611.032024.218154973.davem@davemloft.net>
References: <20090609171151.GM20823@sequoia.sous-sol.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, andy@greyhouse.net
To: chrisw@sous-sol.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20090609171151.GM20823@sequoia.sous-sol.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Chris Wright <chrisw@sous-sol.org>
Date: Tue, 9 Jun 2009 10:11:51 -0700

> DMA buffer is mapped w/ NET_IP_ALIGN accounted, unmapped w/out.
> Dma debugging generates this warning.  Simple fix below.
> 
> [   76.356509] ixgbe 0000:04:00.0: DMA-API: device driver frees DMA
> memory with different size [device address=0x00000000fff7f022] [map
> size=1524 bytes] [unmap size=1522 bytes]
> ...
> [   76.440333]  [<ffffffffa000247f>] ixgbe_clean_rx_irq+0x123/0x41b [ixgbe]
> ...
> [   76.551151] Mapped at:
> [   76.553582]  [<ffffffff811bd745>] debug_dma_map_page+0x4d/0xf8
> [   76.559584]  [<ffffffffa00012d4>] ixgbe_alloc_rx_buffers+0x204/0x2af [ixgbe]
> 
> Signed-off-by: Chris Wright <chrisw@sous-sol.org>
> ---
> Fix is against v2.6.30-rc8-73-g3af968e, but still applies to net-next.

I'll leave this for Jeff to suck into his queue.   Thanks Chris.

------------------------------------------------------------------------------
Crystal Reports - New Free Runtime and 30 Day Trial
Check out the new simplified licensing option that enables unlimited
royalty-free distribution of the report engine for externally facing 
server and web deployment.
http://p.sf.net/sfu/businessobjects
