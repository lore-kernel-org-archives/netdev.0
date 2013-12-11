From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net 2/8] sfc: PTP: Moderate log message on event queue
 overflow
Date: Wed, 11 Dec 2013 02:20:39 +0000
Message-ID: <1386728439.1516.248.camel@bwh-desktop.uk.level5networks.com>
References: <1386726826.1516.238.camel@bwh-desktop.uk.level5networks.com>
	 <1386728153.8168.27.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-net-drivers@solarflare.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:10019 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750942Ab3LKCUn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 21:20:43 -0500
In-Reply-To: <1386728153.8168.27.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-12-10 at 18:15 -0800, Joe Perches wrote:
> On Wed, 2013-12-11 at 01:53 +0000, Ben Hutchings wrote:
> > From: Laurence Evans <levans@solarflare.com>
> []
> > diff --git a/drivers/net/ethernet/sfc/ptp.c b/drivers/net/ethernet/sfc/ptp.c
> []
> > @@ -270,6 +271,7 @@ struct efx_ptp_data {
> >  	struct list_head evt_list;
> >  	struct list_head evt_free_list;
> >  	spinlock_t evt_lock;
> > +	bool evt_overflow;
> 
> It might be nice to move the bools in this struct together
> to reduce the number of struct holes.

There's only one of these per device.  I don't think saving a few bytes
outweighs the benefit of having related fields grouped together.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
