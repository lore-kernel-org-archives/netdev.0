From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: RE: [PATCH] Increase virtual FIFOs in ucc_geth.
Date: Tue, 11 Dec 2007 11:11:59 +0100
Message-ID: <1197367919.6790.3.camel@gentoo-jocke.transmode.se>
References: <1197312366-7484-1-git-send-email-Joakim.Tjernlund@transmode.se>
	 <989B956029373F45A0B8AF029708189001B4D901@zch01exm26.fsl.freescale.net>
Reply-To: joakim.tjernlund@transmode.se
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Li Yang <LeoLi@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.transmode.se ([83.241.175.147]:14968 "EHLO
	tmnt04.transmode.se" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751502AbXLKKMF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 05:12:05 -0500
In-Reply-To: <989B956029373F45A0B8AF029708189001B4D901@zch01exm26.fsl.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 2007-12-11 at 17:49 +0800, Li Yang wrote:
> > -----Original Message-----
> > From: Joakim Tjernlund [mailto:Joakim.Tjernlund@transmode.se] 
> > Sent: Tuesday, December 11, 2007 2:46 AM
> > To: Li Yang-r58472 <LeoLi@freescale.com> Netdev
> > Cc: Joakim Tjernlund
> > Subject: [PATCH] Increase virtual FIFOs in ucc_geth.
> > 
> > Increase UCC_GETH_URFS_INIT to 1152 and
> > UCC_GETH_UTFS_INIT to 896 to avoid HW Overrun/Underrun.
> 
> Please be noted that these values are only used for 10/100Mbps speed.
> Did you get Overrun in 10/100M mode?

I get both TX Underrun and RX overrun in 100Mbps, FD, just
by running a tftp transfer. It feels like the URFET and/or URSFET
isn't working. Why I don't know. CPU is MPC832x

  Jocke

> 
> - Leo
> 
> > 
> > Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> > ---
> >  drivers/net/ucc_geth.h |    4 ++--
> >  1 files changed, 2 insertions(+), 2 deletions(-)
> > 
> > diff --git a/drivers/net/ucc_geth.h b/drivers/net/ucc_geth.h 
> > index bb4dac8..d3f030b 100644
> > --- a/drivers/net/ucc_geth.h
> > +++ b/drivers/net/ucc_geth.h
> > @@ -923,11 +923,11 @@ struct ucc_geth_hardware_statistics {
> >  #define PHY_CHANGE_TIME                         2
> >  
> >  /* Fast Ethernet (10/100 Mbps) */
> > -#define UCC_GETH_URFS_INIT                      512	/* Rx 
> > virtual FIFO size
> > +#define UCC_GETH_URFS_INIT                      1152	/* Rx 
> > virtual FIFO size
> >  							 */
> >  #define UCC_GETH_URFET_INIT                     256	/* 1/2 urfs */
> >  #define UCC_GETH_URFSET_INIT                    384	/* 3/4 urfs */
> > -#define UCC_GETH_UTFS_INIT                      512	/* Tx 
> > virtual FIFO size
> > +#define UCC_GETH_UTFS_INIT                      896	/* Tx 
> > virtual FIFO size
> >  							 */
> >  #define UCC_GETH_UTFET_INIT                     256	/* 1/2 utfs */
> >  #define UCC_GETH_UTFTT_INIT                     128
> > --
> > 1.5.3.6
> > 
> > 
> 
> 
