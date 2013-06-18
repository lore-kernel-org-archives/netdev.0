From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/5] net, atm/ambassader: convert skb->tail
 into skb_tail_pointer(skb)
Date: Mon, 17 Jun 2013 17:13:08 -0700 (PDT)
Message-ID: <20130617.171308.80263867629315296.davem@davemloft.net>
References: <bb5cc0b762102c6a6a56bbd2067c7e539abfb2a6.1371200138.git.yamahata@valinux.co.jp>
	<20130617020109.GB15043@verge.net.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yamahata@valinux.co.jp, netdev@vger.kernel.org,
	chas@cmf.nrl.navy.mil
To: horms@verge.net.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40837 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751549Ab3FRANJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jun 2013 20:13:09 -0400
In-Reply-To: <20130617020109.GB15043@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <horms@verge.net.au>
Date: Mon, 17 Jun 2013 11:01:09 +0900

> On Fri, Jun 14, 2013 at 05:58:31PM +0900, Isaku Yamahata wrote:
>> The change set of 27a884dc, "[SK_BUFF]: Convert skb->tail to sk_buff_data_t"
>> converted skb->tail from pointer into sk_buff_data_t. It missed skb->tail
>> in drivers/atm/ambassador.c.
>> This patch converts skb->tail into skb_tail_pointer(skb).
>> 
>> Found by inspection. Compile tested only.
>> 
>> Cc: Simon Horman <horms@verge.net.au>
>> Cc: Chas Williams <chas@cmf.nrl.navy.mil>
>> Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
> 
> Reviewed-by: Simon Horman <horms@verge.net.au>

Applied.
