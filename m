From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 66/77] mac80211_hwsim: convert to internal
 net_device_stats
Date: Sat, 21 Mar 2009 22:49:50 -0700 (PDT)
Message-ID: <20090321.224950.114687051.davem@davemloft.net>
References: <20090321053527.316395697@vyatta.com>
	<20090321053717.601771143@vyatta.com>
	<1237633705.5100.172.camel@johannes.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, j@w1.fi, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43738
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752631AbZCVFuD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2009 01:50:03 -0400
In-Reply-To: <1237633705.5100.172.camel@johannes.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Sat, 21 Mar 2009 12:08:25 +0100

> On Fri, 2009-03-20 at 22:36 -0700, Stephen Hemminger wrote:
> > plain text document attachment (hwsim.patch)
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> > 
> > 
> > --- a/drivers/net/wireless/mac80211_hwsim.c	2009-03-20 21:45:40.802964051 -0700
> > +++ b/drivers/net/wireless/mac80211_hwsim.c	2009-03-20 22:26:02.959027480 -0700
> > @@ -739,10 +739,16 @@ static struct device_driver mac80211_hws
> >  	.name = "mac80211_hwsim"
> >  };
> >  
> > +static const struct net_device_ops hwsim_netdev_ops = {
> 
> this, and a few others I think, have wrong subjects.

I'll fix it up, as needed.
