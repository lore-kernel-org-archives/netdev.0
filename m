From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] iproute2: enable setting rto_min, rtt and rttvar in	tc-esque
 units
Date: Wed, 19 Sep 2007 15:21:54 -0700
Message-ID: <46F1A102.3030403@hp.com>
References: <200709182015.NAA25590@tardy.cup.hp.com>	<20070919145133.7aff0a5b@freepuppy.rosehill.hemminger.net> <20070919.150312.31444471.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:35540 "EHLO palrel10.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750943AbXISWWN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Sep 2007 18:22:13 -0400
In-Reply-To: <20070919.150312.31444471.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>>Enable users of ip to specify the times for rtt, rttvar and rto_min
>>>in human-friendly terms a la "tc" while maintaining backwards 
>>>compatability with the previous "raw" mechanism.  Builds upon
>>>David Miller's uncommited patch to set rto_min.
>>>
>>>Signed-off-by: Rick Jones <rick.jones2@hp.com>
>>
>>Thanks, I'll put it in the 2.6.24 version of iproute2 (assuming dave
>>takes the rto_min patch).
> 
> If you're talking about the kernel side, Linus's tree already
> has the per-route rto_min stuff.

I was testing the patch using a 2.6.23-rc5 kernel after I noticed from 
reading the changelog that the rto_min change went in there.  It would 
be very nice if it were possible to be in the .23 version of iproute2, 
but I can easily see where things might be a bit late for that.

Meanwhile I'll let the customer know that a way (short of writing their 
own util I guess :) to set the rto_min will be in at least .24

thanks,

rick jones
