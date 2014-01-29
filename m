From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH 2/2] net: ip, ipv6: handle gso skbs in forwarding path
Date: Wed, 29 Jan 2014 11:53:47 +0100
Message-ID: <20140129105347.GF30123@breakpoint.cc>
References: <1390810971-23959-1-git-send-email-fw@strlen.de>
 <1390810971-23959-2-git-send-email-fw@strlen.de>
 <1390846967.27806.75.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140128002707.GA12308@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:46344 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750925AbaA2Kxt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jan 2014 05:53:49 -0500
Content-Disposition: inline
In-Reply-To: <20140128002707.GA12308@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:
> > TCP stream not using DF flag are very unlikely to care if we adjust
> > their MTU (lowering gso_size) at this point ?
> 
> UDP shouldn't be a problem, too.

Sorry for late reply, but how can this be safe for UDP?
We should make sure that peer sees original, unchanged datagram?

And only solution for UDP that I can see is to do sw segmentation (i.e.
create ip fragments).

Thanks,
Florian
