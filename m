From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 4/5] pxa168_eth: convert skb->end into
 skb_end_pointer(skb)
Date: Mon, 17 Jun 2013 17:13:27 -0700 (PDT)
Message-ID: <20130617.171327.1219993454611250119.davem@davemloft.net>
References: <bb5cc0b762102c6a6a56bbd2067c7e539abfb2a6.1371200138.git.yamahata@valinux.co.jp>
	<e9e0e51be02aec40989c4715466d0142381929fe.1371200138.git.yamahata@valinux.co.jp>
	<20130617020150.GC15043@verge.net.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yamahata@valinux.co.jp, netdev@vger.kernel.org
To: horms@verge.net.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40864 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751856Ab3FRAN2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jun 2013 20:13:28 -0400
In-Reply-To: <20130617020150.GC15043@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <horms@verge.net.au>
Date: Mon, 17 Jun 2013 11:01:50 +0900

> On Fri, Jun 14, 2013 at 05:58:34PM +0900, Isaku Yamahata wrote:
>> The change set of 4305b541, "[SK_BUFF]: Convert skb->end to sk_buff_data_t"
>> converted skb->end from pointer type to sk_buff_data_t.
>> The pointed value should be accessed via skb_end_pointer().
>> 
>> Since arm arch doesn't define NET_SKBUFF_DATA_USES_OFFSET,
>> skb->end is effectively pointer. So it doesn't cause a real problem.
>> But this patch is good for consistency.
>> 
>> Found by inspection. Compile tested only.
>> 
>> Cc: Simon Horman <horms@verge.net.au>
>> Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
> 
> Reviewed-by: Simon Horman <horms@verge.net.au>

Applied.
