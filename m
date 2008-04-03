From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [RFC,PATCH] loopback: calls netif_receive_skb() instead of	netif_rx()
Date: Thu, 3 Apr 2008 16:06:00 +0200
Message-ID: <20080403140600.GA4507@ucw.cz>
References: <47BDC848.50607@cosmosbay.com> <20080226.182120.183405235.davem@davemloft.net> <47C92F49.4070100@cosmosbay.com> <20080323.032949.194309002.davem@davemloft.net> <47E6A5FD.6060407@cosmosbay.com> <20080331094823.GA11651@elte.hu> <47F0B66C.6080404@cosmosbay.com> <20080331101237.GA12324@elte.hu> <47F1FE0A.9090501@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758788AbYDCOGg@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <47F1FE0A.9090501@cosmosbay.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

> >the rule on x86 should be something like this: on 4K 
> >stacks and 64-bit [which have irqstacks] free stack 
> >space can go as low as 25%. On 8K stacks [which doesnt 
...
>   32 bits and 4K stacks (separate irq stacks) : can use 
>   up to 25% of stack

I think ingo meant 'up to 75% used'.


-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
