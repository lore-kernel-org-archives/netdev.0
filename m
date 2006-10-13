From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [NET] reduce sizeof(struct inet_peer), cleanup, change
 in peer_check_expire()
Date: Thu, 12 Oct 2006 21:18:43 -0700 (PDT)
Message-ID: <20061012.211843.15264081.davem@davemloft.net>
References: <452EA214.7080905@cosmosbay.com>
	<20061012.151529.95506153.davem@davemloft.net>
	<452F0E7B.3010701@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:42421
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751616AbWJMESm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Oct 2006 00:18:42 -0400
To: dada1@cosmosbay.com
In-Reply-To: <452F0E7B.3010701@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 13 Oct 2006 05:56:43 +0200

> 2^31 is 2147483648
> 
> Thats a *lot* of timer ticks, an inet_peer entry should not stay in 
> unused_list for more than 10 minutes.

My bad, I thought the time was compared to the creation time
not the time at which it was added to the unused list.

I like your patch and I'll apply it.

Thanks Eric.
