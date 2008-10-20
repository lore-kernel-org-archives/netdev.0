From: Divy Le Ray <divy@chelsio.com>
Subject: Re: cxgb3: Fix kernel crash caused by uninitialized l2t_entry.arpq
Date: Mon, 20 Oct 2008 10:10:20 -0700
Message-ID: <48FCBB7C.9070504@chelsio.com>
References: <ada63nqsyxp.fsf@cisco.com> <20081017.163113.225289906.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, jeff@garzik.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:17581 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755563AbYJTRKa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2008 13:10:30 -0400
In-Reply-To: <20081017.163113.225289906.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Roland Dreier <rdreier@cisco.com>
> Date: Fri, 17 Oct 2008 14:18:26 -0700
>
>   
>> Commit 147e70e6 ("cxgb3: Use SKB list interfaces instead of home-grown
>> implementation.") causes a crash in t3_l2t_send_slow() when an iWARP
>> connection request is received.  This is because the new l2t_entry.arpq
>> skb queue is never initialized, and therefore trying to add an skb to
>> it causes a NULL dereference.  With the old code there was no need to
>> initialize the queues because the l2t_entry structures were zeroed,
>> and the code used NULL to mean empty.
>>
>> Fix this by adding __skb_queue_head_init() when all the l2t_entry
>> structures get allocated.
>>
>> Signed-off-by: Roland Dreier <rolandd@cisco.com>
>>     
>
> Acked-by: David S. Miller <davem@davemloft.net>
>   
Acked-by: Divy Le ray <divy@chelsio.com>
