From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 2/7] sfc: Add channel specific receive_skb
 handler and post_remove callback
Date: Wed, 18 Jul 2012 19:42:42 +0100
Message-ID: <1342636962.2617.68.camel@bwh-desktop.uk.solarflarecom.com>
References: <1342635392.2617.52.camel@bwh-desktop.uk.solarflarecom.com>
	 <1342635600.2617.54.camel@bwh-desktop.uk.solarflarecom.com>
	 <20120718.113256.279646201702165485.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	<ajackson@solarflare.com>, <richardcochran@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:58888 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755470Ab2GRSmq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 14:42:46 -0400
In-Reply-To: <20120718.113256.279646201702165485.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-07-18 at 11:32 -0700, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Wed, 18 Jul 2012 19:20:00 +0100
> 
> > +	void (*receive_skb)(struct efx_channel *, struct sk_buff *);
> 
> This looks to me like a conduit for proprietary features implemented
> in a binary-only blob.
> 
> I understand how you're using here for PTP, but you're really openning
> the door for things I really wouldn't be very happy about.

Through all the functions that, er, aren't exported?

Even in the out-of-tree version of sfc there is no receive path hook any
more; I converted the client driver that wanted it (which is under GNU
GPL, thank you very much) to use netfilter.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
