From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net_sched: pfifo_head_drop problem
Date: Wed, 05 Jan 2011 13:39:40 -0800 (PST)
Message-ID: <20110105.133940.179942285.davem@davemloft.net>
References: <1294246850.2775.244.camel@edumazet-laptop>
	<1294259702.2723.22.camel@edumazet-laptop>
	<20110105205217.GC10322@nuttenaction>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, fw@strlen.de,
	kaber@trash.net, shemminger@vyatta.com, jarkao2@gmail.com
To: hagen@jauu.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52015
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752263Ab1AEVjI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jan 2011 16:39:08 -0500
In-Reply-To: <20110105205217.GC10322@nuttenaction>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hagen Paul Pfeifer <hagen@jauu.net>
Date: Wed, 5 Jan 2011 21:52:17 +0100

> * Eric Dumazet | 2011-01-05 21:35:02 [+0100]:
> 
>>My mid term suggestion would be to change things so that
>>sch->bstats.bytes and sch->bstats.packets are incremented in dequeue()
>>only, not at enqueue() time. We also could add drop_bytes/drop_packets
>>and provide estimations of drop rates.
>>
>>It would be more sensible anyway for very low speeds, and big bursts.
>>Right now, if we drop packets, they still are accounted in byte/packets
>>abolute counters and rate estimators.
>>
>>Before this mid term change, this patch makes pfifo_head_drop behavior
>>similar to other qdiscs in case of drops :
>>Dont decrement sch->bstats.bytes and sch->bstats.packets
> 
> Thanks Stephen and Erik for spotting this bug!
> 
>>Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> 
> Acked-by: Hagen Paul Pfeifer <hagen@jauu.net>

Applied and queued up for -stable, thanks.
