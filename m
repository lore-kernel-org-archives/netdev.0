From: Ingo Molnar <mingo@elte.hu>
Subject: Re: boot crash in arp_error_report()
Date: Fri, 28 May 2010 10:05:31 +0200
Message-ID: <20100528080531.GA9893@elte.hu>
References: <alpine.LFD.2.00.1005271213091.3689@i5.linux-foundation.org>
 <1274989637.2446.1.camel@edumazet-laptop>
 <1274991504.2446.13.camel@edumazet-laptop>
 <20100527.161011.104042698.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, torvalds@linux-foundation.org,
	tglx@linutronix.de, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:59332 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755853Ab0E1IFm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 May 2010 04:05:42 -0400
Content-Disposition: inline
In-Reply-To: <20100527.161011.104042698.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* David Miller <davem@davemloft.net> wrote:

> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 27 May 2010 22:18:24 +0200
> 
> > [PATCH] net: fix __neigh_event_send()
> > 
> > commit 7fee226ad23 (net: add a noref bit on skb dst) missed one spot
> > where an skb is enqueued, with a possibly not refcounted dst entry.
> > 
> > __neigh_event_send() inserts skb into arp_queue, so we must make sure
> > dst entry is refcounted, or dst entry can be freed by garbage collector
> > after caller exits from rcu protected section.
> > 
> > Reported-by: Ingo Molnar <mingo@elte.hu>
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> 
> Applied, thanks Eric.
> 
> Ingo can we get a confirmation that this fixes the bootup crash?

Sure, will let you know how it goes.

Thanks,

	Ingo
