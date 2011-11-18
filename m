From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2: switch to build_skb() infrastructure
Date: Fri, 18 Nov 2011 02:09:05 -0500 (EST)
Message-ID: <20111118.020905.956112543630839327.davem@davemloft.net>
References: <1321378205.2856.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1321591644.8833.1.camel@HP1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, eilong@broadcom.com
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58671 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752576Ab1KRHJK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2011 02:09:10 -0500
In-Reply-To: <1321591644.8833.1.camel@HP1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 17 Nov 2011 20:47:24 -0800

> 
> On Tue, 2011-11-15 at 09:30 -0800, Eric Dumazet wrote:
>> This is very similar to bnx2x conversion, but bnx2 only requires 16bytes
>> alignement at start of the received frame to store its l2_fhdr, so goal
>> was not to reduce skb truesize (in fact it should not change after this
>> patch)
>> 
>> Using build_skb() reduces cache line misses in the driver, since we
>> use cache hot skb instead of cold ones. Number of in-flight sk_buff
>> structures is lower, they are more likely recycled in SLUB caches
>> while still hot.
>> 
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>> CC: Michael Chan <mchan@broadcom.com>
>> CC: Eilon Greenstein <eilong@broadcom.com>
> 
> Looks good.  Thanks.
> 
> Reviewed-by: Michael Chan <mchan@broadcom.com>

Applied, thanks everyone.
