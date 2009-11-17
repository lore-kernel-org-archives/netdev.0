From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: linux-next: manual merge of the net tree with the net-current
 tree
Date: Tue, 17 Nov 2009 09:00:18 +0100
Message-ID: <4B025812.6060807@hartkopp.net>
References: <20091117131637.3a35f898.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Wolfram Sang <w.sang@pengutronix.de>,
	Christian Pellegrin <chripell@fsfe.org>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Anant Gole <anantgole@ti.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754147AbZKQIAo@vger.kernel.org>
In-Reply-To: <20091117131637.3a35f898.sfr@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Stephen,

Stephen Rothwell wrote:

> Today's linux-next merge of the net tree got a conflict in
> drivers/net/can/Kconfig between commit
> b93cf3f0bb45560d2ce62bdcc2181c40660cfdbf ("can: Fix driver Kconfig
> structure") from the net-current tree 

Indeed this cleanup was made in net-2.6 to fix the Kconfig structure before
2.6.32 is finalized.

The commits

> 3758bf25db8caeec667e4e56e030da0ec3060529 ("can: add TI CAN (HECC)
> driver"), e0000163e30eeb112b41486ea113fd54f64e1f17 ("can: Driver for the
> Microchip MCP251x SPI CAN controllers") and
> afa17a500a3667f66df450100538d06769529bba ("net/can: add driver for mscan
> family & mpc52xx_mscan") from the net tree.

added Kconfig entries right behind the CAN_AT91 driver - and that's because
the net-2.6 patch "can: Fix driver Kconfig structure" refuses to apply cleanly
on net-next-2.6 ...

> 
> I fixed it up (see below) and can carry the fix for a while. (I am not
> sure the fix is entirely correct.)
> 

Yes. You only added the new Kconfig entries (for CAN_TI_HECC, CAN_MCP251X,
CAN_MSCAN, ...) to the patch "can: Fix driver Kconfig structure", right?

These are the only added items in drivers/net/can/Kconfig from net-2.6 to
net-next-2.6.

Thanks,
Oliver
