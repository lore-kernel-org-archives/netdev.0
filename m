From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v2] ipv4: Early TCP socket demux.
Date: Wed, 20 Jun 2012 19:07:44 +0100
Message-ID: <1340215664.2576.12.camel@bwh-desktop.uk.solarflarecom.com>
References: <20120619.163911.2094057156011157978.davem@davemloft.net>
	 <20120619193549.13bcffa7@s6510.linuxnetplumber.net>
	 <20120619.214657.1345825814176201681.davem@davemloft.net>
	 <1340171940.4604.799.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <shemminger@vyatta.com>,
	<netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:34273 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756239Ab2FTSHr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2012 14:07:47 -0400
In-Reply-To: <1340171940.4604.799.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-20 at 07:59 +0200, Eric Dumazet wrote:
> On Tue, 2012-06-19 at 21:46 -0700, David Miller wrote:
> 
> > These numbers can be decreased further, because since we're already
> > looking at the TCP header we can pre-cook the TCP control block in the
> > SKB and skip much of the stuff that tcp_v4_rcv() does since we've done
> > it already in the early demux code.
> 
> It could be done at GRO level and remove one another demux.
> 
> As routers probably have no use of GRO, no need of additional knob.

I don't know what you mean by 'have no use'.  It's enabled anyway, and I
would expect that it's beneficial for some smaller routers.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
