From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] rhashtable: use cond_resched()
Date: Fri, 27 Feb 2015 17:55:30 -0500 (EST)
Message-ID: <20150227.175530.1113665360721267666.davem@davemloft.net>
References: <20150226075354.GA30061@acer.localdomain>
	<1424962236.5565.156.camel@edumazet-glaptop2.roam.corp.google.com>
	<1424964034.5565.162.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, alexei.starovoitov@gmail.com,
	daniel@iogearbox.net, David.Laight@aculab.com, tgraf@suug.ch,
	pablo@netfilter.org, johunt@akamai.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55036 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932288AbbB0Wzd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 17:55:33 -0500
In-Reply-To: <1424964034.5565.162.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 26 Feb 2015 07:20:34 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> If a hash table has 128 slots and 16384 elems, expand to 256 slots
> takes more than one second. For larger sets, a soft lockup is detected.
> 
> Holding cpu for that long, even in a work queue is a show stopper
> for non preemptable kernels.
> 
> cond_resched() at strategic points to allow process scheduler
> to reschedule us.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
