From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] drivers: net: use skb_headlen()
Date: Wed, 14 Apr 2010 16:15:04 -0700 (PDT)
Message-ID: <20100414.161504.149014877.davem@davemloft.net>
References: <1271191700.16881.574.camel@edumazet-laptop>
	<20100414.155949.210580528.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34410
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755332Ab0DNXPA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Apr 2010 19:15:00 -0400
In-Reply-To: <20100414.155949.210580528.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 14 Apr 2010 15:59:49 -0700 (PDT)

> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 13 Apr 2010 22:48:20 +0200
> 
>> replaces (skb->len - skb->data_len) occurrences by skb_headlen(skb)
>> 
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> 
> Applied, thanks Eric.

Eric, there were several typos in this patch and it is clear
that even e1000 wasn't build tested.

You used the mystical "skb_headsize()" instead of "skb_headlen()"
in several locations.

I fixed this up, but please build test your changes no matter
how seemingly trivial next time.

Thanks.
