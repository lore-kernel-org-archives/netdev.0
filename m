From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ppp: fix segfaults introduced by netdev_priv changes
Date: Thu, 18 Dec 2008 19:40:28 -0800 (PST)
Message-ID: <20081218.194028.165029603.davem@davemloft.net>
References: <200812172202.mBHM2GHi012456@bert.katalix.com>
	<20081217.192047.117548302.davem@davemloft.net>
	<494A25C3.1050603@katalix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wangchen@cn.fujitsu.com
To: jchapman@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47809
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752090AbYLSDk0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2008 22:40:26 -0500
In-Reply-To: <494A25C3.1050603@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: James Chapman <jchapman@katalix.com>
Date: Thu, 18 Dec 2008 10:28:19 +0000

> David Miller wrote:
> > From: James Chapman <jchapman@katalix.com>
> > Date: Wed, 17 Dec 2008 22:02:16 GMT
> > 
> >> +	} else
> >> +		ppp_unlock(ppp);
> >> +
> >>  	cardmap_set(&all_ppp_units, ppp->file.index, NULL);
> >>  	ppp->file.dead = 1;
> >>  	ppp->owner = NULL;
> > 
> > James, thanks for this fix.  But you'll need to respin this
> > as it conflicts with the IDR changes that are in net-next-2.6
> > (this cardmap_set call isn't there any more, for example).
> 
> The patch is against net-2.6. I assumed it was appropriate for net-2.6
> since we're on rc8 and ppp has been broken since rc6. :) Sorry I didn't
> mention that in the patch.

That part I missed, I thought it was caused by the conversions
we did only in net-next-2.6

I'll apply your original net-2.6 patch, thanks James!
