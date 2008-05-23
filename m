From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: RE: [PATCH] ucc_geth_ethtool: Fix a few HW stats counters.
Date: Fri, 23 May 2008 09:21:17 +0200
Message-ID: <1211527277.8370.20.camel@gentoo-jocke.transmode.se>
References: <1210665877-6590-1-git-send-email-Joakim.Tjernlund@transmode.se>
	 <4835B60F.6070904@garzik.org>
	 <989B956029373F45A0B8AF02970818900250D550@zch01exm26.fsl.freescale.net>
Reply-To: joakim.tjernlund@transmode.se
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, Netdev <netdev@vger.kernel.org>
To: Li Yang <LeoLi@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.transmode.se ([83.241.175.147]:52107 "EHLO
	tmnt04.transmode.se" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752210AbYEWHVW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2008 03:21:22 -0400
In-Reply-To: <989B956029373F45A0B8AF02970818900250D550@zch01exm26.fsl.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 2008-05-23 at 11:04 +0800, Li Yang wrote:
> > -----Original Message-----
> > From: Jeff Garzik [mailto:jeff@garzik.org] 
> > Sent: Friday, May 23, 2008 2:06 AM
> > To: Joakim Tjernlund
> > Cc: Netdev; Li Yang
> > Subject: Re: [PATCH] ucc_geth_ethtool: Fix a few HW stats counters.
> > 
> > Joakim Tjernlund wrote:
> > > Noticed that ethtool -S didn't display tx-xxx-frames correctly.
> > > Fix it and a few others while I am there. Strangely, the 
> > > rx-jumbo-frames counter still counts pkgs even though I think there 
> > > isn't any packtes above 1518.
> > > 
> > > Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> > > ---
> > > 
> > > Havn't seen this go in or ACK/NACK. Resending.
> > > 
> > >  drivers/net/ucc_geth_ethtool.c |    3 +--
> > >  1 files changed, 1 insertions(+), 2 deletions(-)
> > 
> > still looking for maintainer's ack...
> 
> This patch still need some change.
> 
> Joakim,
> 
> Could you respin this patch without deleting the two counters?

Very busy ATM, release coming up here so I need to focus on that.
Feel free to respin yourself meanwhile.
