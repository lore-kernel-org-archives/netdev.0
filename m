From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 4/6] alx: separate link speed/duplex fields
Date: Fri, 21 Jun 2013 22:43:25 +0200
Message-ID: <1371847405.8936.1.camel@jlt4.sipsolutions.net>
References: <1371766494-18979-1-git-send-email-johannes@sipsolutions.net>
	 <1371766494-18979-5-git-send-email-johannes@sipsolutions.net>
	 <1371818249.8771.19.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:53207 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1945951Ab3FUUn1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jun 2013 16:43:27 -0400
In-Reply-To: <1371818249.8771.19.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-06-21 at 13:37 +0100, Ben Hutchings wrote:
> On Fri, 2013-06-21 at 00:14 +0200, Johannes Berg wrote:
> > As suggested by Ben Hutchings, use separate fields to track
> > current link speed and duplex setting.
> > 
> > Reported-by: Ben Hutchings <ben@decadent.org.uk>
> > Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
> > ---
> >  drivers/net/ethernet/atheros/alx/ethtool.c |  35 ++------
> >  drivers/net/ethernet/atheros/alx/hw.c      | 136 ++++++++++++-----------------
> >  drivers/net/ethernet/atheros/alx/hw.h      |  24 ++++-
> >  drivers/net/ethernet/atheros/alx/main.c    |  37 ++++----
> >  4 files changed, 106 insertions(+), 126 deletions(-)
> > 
> > diff --git a/drivers/net/ethernet/atheros/alx/ethtool.c b/drivers/net/ethernet/atheros/alx/ethtool.c
> > index 50a91d0..2170b61 100644
> > --- a/drivers/net/ethernet/atheros/alx/ethtool.c
> > +++ b/drivers/net/ethernet/atheros/alx/ethtool.c
> > @@ -58,7 +58,8 @@ static int alx_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
> >  			  SUPPORTED_100baseT_Full |
> >  			  SUPPORTED_Autoneg |
> >  			  SUPPORTED_TP |
> > -			  SUPPORTED_Pause;
> > +			  SUPPORTED_Pause |
> > +			  SUPPORTED_Asym_Pause;
> >  	if (alx_hw_giga(hw))
> >  		ecmd->supported |= SUPPORTED_1000baseT_Full;
> > 
> [...]
> 
> This hunk belongs in patch 6.

Good catch, thanks. I'll resend 4 and 6 (tomorrow or so).

johannes
