From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [-MM, FIX V3] e1000e: incorporate napi_struct changes
 from net-2.6.24.git
Date: Wed, 12 Sep 2007 23:55:21 -0700 (PDT)
Message-ID: <20070912.235521.41654166.davem@davemloft.net>
References: <18146.21773.295381.108336@robur.slu.se>
	<20070912.075324.98878193.davem@davemloft.net>
	<46E816F5.9010409@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, akpm@linux-foundation.org,
	jeff@garzik.org, netdev@vger.kernel.org
To: auke-jan.h.kok@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:38184
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758250AbXIMGzj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2007 02:55:39 -0400
In-Reply-To: <46E816F5.9010409@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Date: Wed, 12 Sep 2007 09:42:29 -0700

> David Miller wrote:
> > 
> > diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
> > index 7b0bcdb..58bb758 100644
> > --- a/drivers/net/e1000/e1000_main.c
> > +++ b/drivers/net/e1000/e1000_main.c
> > @@ -3944,7 +3944,7 @@ e1000_clean(struct napi_struct *napi, int budget)
> >  	                  &work_done, budget);
> >  
> >  	/* If no Tx and not enough Rx work done, exit the polling mode */
> > -	if ((tx_cleaned && (work_done < budget)) ||
> > +	if ((!tx_cleaned && (work_done < budget)) ||
> >  	   !netif_running(poll_dev)) {
> >  quit_polling:
> >  		if (likely(adapter->itr_setting & 3))
> 
> 
> Ack, this is exactly what I did to fix e1000e as well.

Thanks for reviewing.
