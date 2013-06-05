From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb3: Correct comparisons and calculations
 using skb->tail and skb-transport_header
Date: Tue, 04 Jun 2013 17:38:37 -0700 (PDT)
Message-ID: <20130604.173837.694607398273174665.davem@davemloft.net>
References: <1370333476-17699-1-git-send-email-roy.qing.li@gmail.com>
	<20130604132353.GF3068@verge.net.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roy.qing.li@gmail.com, netdev@vger.kernel.org
To: horms@verge.net.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60719 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750941Ab3FEAii (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 20:38:38 -0400
In-Reply-To: <20130604132353.GF3068@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <horms@verge.net.au>
Date: Tue, 4 Jun 2013 22:23:53 +0900

> On Tue, Jun 04, 2013 at 04:11:16PM +0800, roy.qing.li@gmail.com wrote:
>> From: Li RongQing <roy.qing.li@gmail.com>
>> 
>> This corrects an regression introduced by "net: Use 16bits for *_headers
>> fields of struct skbuff" when NET_SKBUFF_DATA_USES_OFFSET is not set. In
>> that case skb->tail will be a pointer whereas skb->transport_header
>> will be an offset from head. This is corrected by using wrappers that
>> ensure that comparisons and calculations are always made using pointers.
>> 
>> Cc: Simon Horman <horms@verge.net.au>
>> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> 
> Reviewed-by: Simon Horman <horms@verge.net.au>

Applied.
