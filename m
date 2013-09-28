From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: net_secret should not depend on TCP
Date: Sat, 28 Sep 2013 15:20:42 -0700 (PDT)
Message-ID: <20130928.152042.893883191246097959.davem@davemloft.net>
References: <20130924054532.GA24446@order.stressinduktion.org>
	<1380028797.3165.65.camel@edumazet-glaptop>
	<20130924235147.GA9335@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, therbert@google.com,
	netdev@vger.kernel.org, jesse.brandeburg@intel.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33694 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755076Ab3I1WNn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Sep 2013 18:13:43 -0400
In-Reply-To: <20130924235147.GA9335@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Wed, 25 Sep 2013 01:51:47 +0200

> On Tue, Sep 24, 2013 at 06:19:57AM -0700, Eric Dumazet wrote:
>> From: Eric Dumazet <edumazet@google.com>
>> 
>> A host might need net_secret[] and never open a single socket. 
>> 
>> Problem added in commit aebda156a570782
>> ("net: defer net_secret[] initialization")
>> 
>> Based on prior patch from Hannes Frederic Sowa.
>> 
>> Reported-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
> 
> FWIW, I reviewed that the loop indeed cannot block and gave the patch a
> quick test drive. Also, the ipv6_hash_secret is only used by the ehash
> functions. So this is a superior patch than mine:
> 
> Acked-by: Hannes Frederic Sowa <hannes@strressinduktion.org>

Applied and queued up for -stable, thanks.
