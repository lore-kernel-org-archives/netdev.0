From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/5] mv643xx_eth.c: convert skb->end into
 skb_end_poitner(skb)
Date: Mon, 17 Jun 2013 17:13:20 -0700 (PDT)
Message-ID: <20130617.171320.2300960990080770267.davem@davemloft.net>
References: <bb5cc0b762102c6a6a56bbd2067c7e539abfb2a6.1371200138.git.yamahata@valinux.co.jp>
	<7629c2a65cffd7b61d100703567e027a2850c3c6.1371200138.git.yamahata@valinux.co.jp>
	<20130617020218.GD15043@verge.net.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yamahata@valinux.co.jp, netdev@vger.kernel.org,
	buytenh@wantstofly.org
To: horms@verge.net.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40850 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751856Ab3FRANV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jun 2013 20:13:21 -0400
In-Reply-To: <20130617020218.GD15043@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <horms@verge.net.au>
Date: Mon, 17 Jun 2013 11:02:18 +0900

> On Fri, Jun 14, 2013 at 05:58:33PM +0900, Isaku Yamahata wrote:
>> The change set of 4305b541 "[SK_BUFF]: Convert skb->end to sk_buff_data_t"
>> converted skb->end from pointer to sk_buff_data_t.
>> The pointed value should be accessed via skb_end_pointer().
>> 
>> Since arm or ppc arch doesn't define NET_SKBUFF_DATA_USES_OFFSET,
>> skb->end is effectively pointer. So it doesn't cause a real problem.
>> But this patch is good for consistency.
>> 
>> Found by inspection. Compile test only.
>> 
>> Cc: Simon Horman <horms@verge.net.au>
>> Cc: Lennert Buytenhek <buytenh@wantstofly.org>
>> Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
> 
> Reviewed-by: Simon Horman <horms@verge.net.au>

Applied.
