From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: MV643xx Ethernet 2.6 driver update
Date: Thu, 27 Jan 2005 04:56:26 -0500
Message-ID: <41F8BACA.1020302@pobox.com>
References: <20050117184019.GA24655@xyzzy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Ralf Baechle <ralf@linux-mips.org>,
        Manish Lachwani <mlachwani@mvista.com>,
        Brian Waite <brian@waitefamily.us>,
        "Steven J. Hill" <sjhill@realitydiluted.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Dale Farnsworth <dale@farnsworth.org>
In-Reply-To: <20050117184019.GA24655@xyzzy>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dale Farnsworth wrote:
> While porting the mv643xx ethernet driver to 2.6 and for use on PPC, I
> modified it to use the device driver model, fixed the hardware checksum
> support, and did some miscellaneous bug fixes and cleanups.
> 
> The following changes are included:
> 	
>  A. Remove redundant or unneeded code.
>  B. Replace fixed count spins with udelay/msleep waits on hardware status bits
>  C. Fix code to enable hardware checksum generation for TX packets
>  D. Convert from pci_map_* to dma_map_* interface
>  E. Add device driver model support.
>  F. Add support for several configurable parameters via platform_device
>  G. Make use of MV64340_RX_QUEUE_FILL_ON_TASK macro consistent.
>  H. Simplify mv64340_eth_set_rx_mode()
>  I. Clean up receive buffer sizing
>  J. Call netif_carrier_off/netif_carrier_on on a link down/up condition
>  K. Add support for PHYs/boards that don't support autonegotiation.
> 
> Change E is the only one that modifies the driver interface.
> 
> Change G was sent to me by Steven J Hill <sjhill1@rockwellcollins.com>.
> Change K was sent to me by Brian Waite <brian@waitefamily.us>.
> 
> The first 6 changes were submitted to LKLM on Dec. 13 2004.  Comments
> were received only from Christoph Hellwig <hch@infradead.org> and have
> been addressed.  Changes G-K have been added since then.
> 
> I have some additional (mostly cosmetic, but still significant) cleanups,
> but I'd like to get these in the queue first.
> 
> Thanks,
> Dale Farnsworth
> 
> Please do a
> 
> 	bk pull bk://dfarnsworth.bkbits.net/netdev-2.6-mv643xx-enet


Ouch:

When using BitKeeper, you need to make sure your changes are the only 
ones in the tree.  It doesn't work for me to pull:

mv643xx-enet -> jgarzik-mv643xx-enet -> net-drivers-2.6 -> linus

because that would require pulling the entire netdev-2.6 tree up through 
that chain.

	Jeff
