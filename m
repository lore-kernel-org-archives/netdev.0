From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: RE: [PATCH] Increase virtual FIFOs in ucc_geth.
Date: Tue, 11 Dec 2007 11:57:56 +0100
Message-ID: <1197370676.6790.17.camel@gentoo-jocke.transmode.se>
References: <1197312366-7484-1-git-send-email-Joakim.Tjernlund@transmode.se>
	 <989B956029373F45A0B8AF029708189001B4D901@zch01exm26.fsl.freescale.net>
	 <1197367919.6790.3.camel@gentoo-jocke.transmode.se>
Reply-To: joakim.tjernlund@transmode.se
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Li Yang <LeoLi@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.transmode.se ([83.241.175.147]:17791 "EHLO
	tmnt04.transmode.se" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750848AbXLKK56 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 05:57:58 -0500
In-Reply-To: <1197367919.6790.3.camel@gentoo-jocke.transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 2007-12-11 at 11:11 +0100, Joakim Tjernlund wrote:
> On Tue, 2007-12-11 at 17:49 +0800, Li Yang wrote:
> > > -----Original Message-----
> > > From: Joakim Tjernlund [mailto:Joakim.Tjernlund@transmode.se] 
> > > Sent: Tuesday, December 11, 2007 2:46 AM
> > > To: Li Yang-r58472 <LeoLi@freescale.com> Netdev
> > > Cc: Joakim Tjernlund
> > > Subject: [PATCH] Increase virtual FIFOs in ucc_geth.
> > > 
> > > Increase UCC_GETH_URFS_INIT to 1152 and
> > > UCC_GETH_UTFS_INIT to 896 to avoid HW Overrun/Underrun.
> > 
> > Please be noted that these values are only used for 10/100Mbps speed.
> > Did you get Overrun in 10/100M mode?
> 
> I get both TX Underrun and RX overrun in 100Mbps, FD, just
> by running a tftp transfer. It feels like the URFET and/or URSFET
> isn't working. Why I don't know. CPU is MPC832x
> 
>   Jocke

I am a bit confused how the RBMR and TBMR is supposed to work. In
ucc_get there is:
 out_be32(&ugeth->p_tx_glbl_pram->tstate, ((u32) function_code) << 24);
 ugeth->p_rx_glbl_pram->rstate = function_code;
First, should not the rx part look the same as tx?
Does programing rstate/tstate replace RBMR and TBMR?

 Jocke
