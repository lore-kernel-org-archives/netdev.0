From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] rtcache remove respin
Date: Tue, 03 Jul 2012 03:56:56 -0700 (PDT)
Message-ID: <20120703.035656.555916230377588198.davem@davemloft.net>
References: <20120701.050243.908285695895815999.davem@davemloft.net>
	<20120701.051556.541026724350825709.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37240 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932324Ab2GCK47 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2012 06:56:59 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id CA078584164
	for <netdev@vger.kernel.org>; Tue,  3 Jul 2012 03:57:00 -0700 (PDT)
In-Reply-To: <20120701.051556.541026724350825709.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Sun, 01 Jul 2012 05:15:56 -0700 (PDT)

> From: David Miller <davem@davemloft.net>
> Date: Sun, 01 Jul 2012 05:02:43 -0700 (PDT)
> 
>> On a SPARC T3-1:
>> 
>> 1) Output route lookup: ~2800 cycles
>> 2) Input route lookups: ~3000 cycles (rpfilter=0)
>>                         ~4300 cycles (rpfilter=1)
> 
> Out of curiosity I got rid of the local table and made all routes
> go into the main table and those numbers above become:
> 
> 1) Output route lookup: ~2500 cycles
> 2) Input route lookups: ~2800 cycles (rpfilter=0)
>                         ~4100 cycles (rpfilter=1)
> 

And with the neighbour patches I posted tonight these numbers are:

1) Output route lookup: ~2150 cycles
2) Input route lookups: ~2600 cycles (rpfilter=0)
                        ~3700 cycles (rpfilter=1)
