From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH 2/2] net: ip, ipv6: handle gso skbs in forwarding path
Date: Tue, 28 Jan 2014 18:37:31 +0100
Message-ID: <20140128173731.GD30123@breakpoint.cc>
References: <1390810971-23959-1-git-send-email-fw@strlen.de>
 <1390810971-23959-2-git-send-email-fw@strlen.de>
 <1390846967.27806.75.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140128085706.GB30123@breakpoint.cc>
 <1390926883.28432.12.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140128171519.GC30123@breakpoint.cc>
 <1390930233.28432.16.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:44262 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755369AbaA1Rhe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jan 2014 12:37:34 -0500
Content-Disposition: inline
In-Reply-To: <1390930233.28432.16.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> I think the xmit will take care of doing the fallback anyway, if skb
> need to be linear or TX checksum be computed. 
> 
> > I think thats the best solution for -net.  I would then try to come up
> > with a version that follows your "shrink gso_size" suggestion for -next.
> 
> Note that I mentioned this MTU thing months ago, and the bug is here
> since years. I do not think its a very urgent matter :)

Fair enough.  I'll see that I have something ready when -next opens.

Thanks Eric.
