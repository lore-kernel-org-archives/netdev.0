From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6-multicast: Fix memory leak in input path.
Date: Sat, 04 Feb 2012 16:49:57 -0500 (EST)
Message-ID: <20120204.164957.1798190312073830760.davem@davemloft.net>
References: <1317149897-14932-1-git-send-email-greearb@candelatech.com>
	<20110927.151616.1706187903528893128.davem@davemloft.net>
	<4F2AC749.5070905@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36328 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753316Ab2BDVuA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2012 16:50:00 -0500
In-Reply-To: <4F2AC749.5070905@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>
Date: Thu, 02 Feb 2012 09:26:33 -0800

> On 09/27/2011 12:16 PM, David Miller wrote:
>> From: greearb@candelatech.com
>> Date: Tue, 27 Sep 2011 11:58:17 -0700
>>
>>> From: Ben Greear<greearb@candelatech.com>
>>>
>>> Have to free the skb before returning if we fail
>>> the fib lookup.
>>>
>>> Signed-off-by: Ben Greear<greearb@candelatech.com>
>>
>> Applied, thanks.
> 
> From what I can tell, this never made it into the 3.0 stable
> series.
> 
> I know that normally you feed things to stable, but please let me
> know if you'd like me to send it to the stable guys instead...

I'll queue this and the other one up for -stable, thanks.
