From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: add some slack to arp monitoring time limits
Date: Fri, 31 Aug 2012 16:37:43 -0400 (EDT)
Message-ID: <20120831.163743.1055530014542819729.davem@davemloft.net>
References: <50351CC5.3030109@genband.com>
	<24655.1345660922@death.nxdomain>
	<20120830220247.GB17263@midget.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, chris.friesen@genband.com, andy@greyhouse.net,
	netdev@vger.kernel.org, ptesarik@suse.cz
To: jbohac@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53440 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754936Ab2HaUhr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2012 16:37:47 -0400
In-Reply-To: <20120830220247.GB17263@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Bohac <jbohac@suse.cz>
Date: Fri, 31 Aug 2012 00:02:47 +0200

> Currently, all the time limits in the bonding ARP monitor are in
> multiples of arp_interval -- the time interval at which the ARP
> monitor is periodically scheduled.
> 
> With a fast network round-trip and a little scheduling latency
> of the ARP monitor work, a limit of n*delta_in_ticks may
> effectively mean (n-1)*delta_in_ticks.
> 
> This is fatal in case of n==1  (the link will stay down
> forever) and makes the behaviour non-deterministic in all the
> other cases.
> 
> Add a delta_in_ticks/2 time slack to all the time limits.
> 
> Signed-off-by: Jiri Bohac <jbohac@suse.cz>

Applied to net-next, thanks.
