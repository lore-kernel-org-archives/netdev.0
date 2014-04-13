From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3.2] ipv6: don't set DST_NOCOUNT for remotely added
 routes
Date: Sun, 13 Apr 2014 19:19:48 -0400 (EDT)
Message-ID: <20140413.191948.1913975381773497028.davem@davemloft.net>
References: <20140410.215420.576903689381200176.davem@davemloft.net>
	<1397392513.10849.75.camel@deadeye.wl.decadent.org.uk>
	<1397430142.10849.91.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stable@vger.kernel.org, sd@queasysnail.net,
	hannes@stressinduktion.org, netdev@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48580 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750769AbaDMXTx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Apr 2014 19:19:53 -0400
In-Reply-To: <1397430142.10849.91.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Mon, 14 Apr 2014 00:02:22 +0100

> From: Sabrina Dubroca <sd@queasysnail.net>
> 
> commit c88507fbad8055297c1d1e21e599f46960cbee39 upstream.
> 
> DST_NOCOUNT should only be used if an authorized user adds routes
> locally. In case of routes which are added on behalf of router
> advertisments this flag must not get used as it allows an unlimited
> number of routes getting added remotely.
> 
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> [bwh: Backported to 3.2: adjust context]
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> ---
> This is untested, but looks almost identical to what you sent for 3.4.
> Please ack/nak.

This looks good to me:

Acked-by: David S. Miller <davem@davemloft.net>
