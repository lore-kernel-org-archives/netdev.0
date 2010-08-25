From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: Fix sysctl_tcp_max_orphans when PAGE_SIZE != 4k
Date: Wed, 25 Aug 2010 00:59:58 -0700 (PDT)
Message-ID: <20100825.005958.242146504.davem@davemloft.net>
References: <20100825071626.GA13681@kryten>
	<20100825071701.GA14962@kryten>
	<1282721941.2467.705.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anton@samba.org, netdev@vger.kernel.org, miltonm@bga.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53209
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751495Ab0HYH7k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 03:59:40 -0400
In-Reply-To: <1282721941.2467.705.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 25 Aug 2010 09:39:01 +0200

> Considering your previous mail, I suggest you add
> 
> 	sysctl_tcp_max_orphans = max(sysctl_tcp_max_orphans,
> 		     percpu_counter_batch * num_possible_cpus());

That seems unnecessary, see my other reply to Anton on how to fix this
skew problem.
