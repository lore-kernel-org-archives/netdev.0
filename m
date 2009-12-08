From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT]: Networking
Date: Tue, 8 Dec 2009 12:51:00 -0800 (PST)
Message-ID: <alpine.LFD.2.00.0912081249060.3560@localhost.localdomain>
References: <20091205.193505.193701079.davem@davemloft.net> <20091208194530.GA24530@elte.hu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:55154 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S966033AbZLHUvT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2009 15:51:19 -0500
In-Reply-To: <20091208194530.GA24530@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Tue, 8 Dec 2009, Ingo Molnar wrote:

> 
> hi Dave,
> 
> i just switched to today's -git tree and there's this new build failure 
> on x86:
> 
>  net/sctp/sysctl.c:251: error: unknown field 'strategy' specified in initializer
>  net/sctp/sysctl.c:251: error: 'sysctl_intvec' undeclared here (not in a function)
> 
> havent looked into it yet - config attached.

That's my mismerge. I should have removed the strategy field too, not just 
the ctr_name. My bad, will fix up,

		Linus
