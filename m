From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/6] llc2: Simplify llc_station
Date: Mon, 17 Sep 2012 13:12:37 -0400 (EDT)
Message-ID: <20120917.131237.518528991078697534.davem@davemloft.net>
References: <1347764982.13258.207.camel@deadeye.wl.decadent.org.uk>
	<20120917.130531.941621987417626917.davem@davemloft.net>
	<20120917.131017.1646567691887140571.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@ghostprotocols.net, netdev@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59422 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752328Ab2IQRMj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2012 13:12:39 -0400
In-Reply-To: <20120917.131017.1646567691887140571.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Mon, 17 Sep 2012 13:10:17 -0400 (EDT)

> From: David Miller <davem@davemloft.net>
> Date: Mon, 17 Sep 2012 13:05:31 -0400 (EDT)
> 
>> From: Ben Hutchings <ben@decadent.org.uk>
>> Date: Sun, 16 Sep 2012 04:09:42 +0100
>> 
>>> There seem to have been some grand plans for llc_station, but as they
>>> haven't been fulfilled it's just unnecessarily complicated.
>> 
>> I went over these a few times, they look correct, so I am going
>> to apply them to net-next.
>> 
>> If there are any problems let's hope that exposure in the tree
>> helps shake those out.
> 
> It doesn't even build properly, please fix this and resubmit:
> 
> ERROR: "sysctl_llc_station_ack_timeout" [net/llc/llc2.ko] undefined!

Actually, since I trusted you when you said you build tested this,
I pushed it out to net-next pre-maturely.

I'm going to fix this meanwhile by simply removing the sysctl that
references this symbol.

But you need to check for me whether that's ok or not.
