From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net-next] net: introduce dev_set_forwarding()
Date: Thu, 07 Nov 2013 16:17:55 -0500 (EST)
Message-ID: <20131107.161755.355597965034457889.davem@davemloft.net>
References: <1383400897.4291.47.camel@edumazet-glaptop2.roam.corp.google.com>
	<1383422330.4291.58.camel@edumazet-glaptop2.roam.corp.google.com>
	<1383584130.1553.2.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, christoph.paasch@uclouvain.be,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55301 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753164Ab3KGVR7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 16:17:59 -0500
In-Reply-To: <1383584130.1553.2.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 4 Nov 2013 16:55:30 +0000

> On Sat, 2013-11-02 at 12:58 -0700, Eric Dumazet wrote:
>> From: Eric Dumazet <edumazet@google.com>
>> 
>> Christoph Paasch and Jerry Chu reported crashes in skb_segment() caused
>> by commit 8a29111c7ca6 ("net: gro: allow to build full sized skb")
>> 
>> skb_segment() only deals with a frag_list chain containing MSS sized
>> fragments. Even if we fix this problem, its better if GRO layer
>> doesn't build skb with a frag_list in the first place, to let TSO
>> packets reaching output devices.
>>  
>> David Miller and Ben Hutchings suggested we keep track of number of
>> forwarding users to be able to :
>> 
>> - Disable LRO
>> - Make sure GRO layer do not use skb frag_list to extend skb capacity
>> 
>> Note that after this patch, LRO is automatically re-enabled if
>> forwarding is disabled on the device, or if a device is removed
>> from a bridge.
> [...]
> 
> Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>

Applied, thanks everyone.
