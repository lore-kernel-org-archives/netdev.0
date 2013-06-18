From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 5/5] staging/rtl8192u: convert skb->tail into
 skb_tail_pointer(skb)
Date: Mon, 17 Jun 2013 17:13:33 -0700 (PDT)
Message-ID: <20130617.171333.1206092427807227985.davem@davemloft.net>
References: <bb5cc0b762102c6a6a56bbd2067c7e539abfb2a6.1371200138.git.yamahata@valinux.co.jp>
	<4e2318187b15be4d81c3b03cd0337506c7008bb8.1371200138.git.yamahata@valinux.co.jp>
	<20130617020305.GE15043@verge.net.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yamahata@valinux.co.jp, netdev@vger.kernel.org,
	gregkh@linuxfoundation.org, devel@driverdev.osuosl.org
To: horms@verge.net.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40877 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751856Ab3FRANk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jun 2013 20:13:40 -0400
In-Reply-To: <20130617020305.GE15043@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <horms@verge.net.au>
Date: Mon, 17 Jun 2013 11:03:05 +0900

> On Fri, Jun 14, 2013 at 05:58:35PM +0900, Isaku Yamahata wrote:
>> The change set of 7a884dc "[SK_BUFF]: Convert skb->tail to sk_buff_data_t"
>> converted skb->tail from pointer into sk_buff_data_t.
>> Thus skb->tail is not always pointer, the area pointed by skb->tail
>> should be accessed via skb_tail_pointer().
>> 
>> Found by inspection. Compile tested only.
>> 
>> Cc: Simon Horman <horms@verge.net.au>
>> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
>> Cc: devel@driverdev.osuosl.org
>> Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
> 
> Reviewed-by: Simon Horman <horms@verge.net.au>

Applied.
