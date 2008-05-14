From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: RE: [PATCH] ucc_geth_ethtool: Fix a few HW stats counters.
Date: Wed, 14 May 2008 12:49:35 +0200
Message-ID: <1210762175.32216.295.camel@gentoo-jocke.transmode.se>
References: <1210665877-6590-1-git-send-email-Joakim.Tjernlund@transmode.se>
	 <989B956029373F45A0B8AF0297081890022E13C3@zch01exm26.fsl.freescale.net>
Reply-To: joakim.tjernlund@transmode.se
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Li Yang <LeoLi@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.transmode.se ([83.241.175.147]:27399 "EHLO
	tmnt04.transmode.se" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754936AbYENKtj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 06:49:39 -0400
In-Reply-To: <989B956029373F45A0B8AF0297081890022E13C3@zch01exm26.fsl.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I didn't see them in my manual so I figured they were extra. If you find
them please let me know where.

On Wed, 2008-05-14 at 18:37 +0800, Li Yang wrote:
> Hi Joakim,
> 
> I admit that I missed one in tx firmware stats.  But why are you
> deleting the other two?
> 
> - Leo
> 
> > -----Original Message-----
> > From: Joakim Tjernlund [mailto:Joakim.Tjernlund@transmode.se] 
> > Sent: Tuesday, May 13, 2008 4:05 PM
> > To: Netdev; Li Yang
> > Cc: Joakim Tjernlund
> > Subject: [PATCH] ucc_geth_ethtool: Fix a few HW stats counters.
> > 
> > Noticed that ethtool -S didn't display tx-xxx-frames correctly.
> > Fix it and a few others while I am there. Strangely, the 
> > rx-jumbo-frames counter still counts pkgs even though I think 
> > there isn't any packtes above 1518.
> > 
> > Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> > ---
> > 
> > Havn't seen this go in or ACK/NACK. Resending.
> > 
> >  drivers/net/ucc_geth_ethtool.c |    3 +--
> >  1 files changed, 1 insertions(+), 2 deletions(-)
> > 
> > diff --git a/drivers/net/ucc_geth_ethtool.c 
> > b/drivers/net/ucc_geth_ethtool.c index a995a3a..0eddf50 100644
> > --- a/drivers/net/ucc_geth_ethtool.c
> > +++ b/drivers/net/ucc_geth_ethtool.c
> > @@ -60,7 +60,6 @@ static char hw_stat_gstrings[][ETH_GSTRING_LEN] = {
> >  	"rx-broadcast-frames",
> >  	"stats-counter-carry",
> >  	"stats-counter-mask",
> > -	"rx-dropped-frames",
> >  };
> >  
> >  static char tx_fw_stat_gstrings[][ETH_GSTRING_LEN] = { @@ 
> > -73,6 +72,7 @@ static char tx_fw_stat_gstrings[][ETH_GSTRING_LEN] = {
> >  	"tx-frames-ok",
> >  	"tx-excessive-differ-frames",
> >  	"tx-256-511-frames",
> > +	"tx-512-1023-frames",
> >  	"tx-1024-1518-frames",
> >  	"tx-jumbo-frames",
> >  };
> > @@ -101,7 +101,6 @@ static char 
> > rx_fw_stat_gstrings[][ETH_GSTRING_LEN] = {
> >  	"rx-vlan-removed",
> >  	"rx-vlan-replaced",
> >  	"rx-vlan-inserted",
> > -	"rx-ip-checksum-errors",
> >  };
> >  
> >  #define UEC_HW_STATS_LEN ARRAY_SIZE(hw_stat_gstrings)
> > --
> > 1.5.5.1
> > 
> > 
> 
> 
