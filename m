From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH -next, V3 0/2] net: force refragmentation for DF
 reassembed skbs
Date: Fri, 22 May 2015 21:26:51 +0200
Message-ID: <20150522192651.GA3629@breakpoint.cc>
References: <1432305171-21932-1-git-send-email-fw@strlen.de>
 <20150522.150310.2248217318352290500.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fw@strlen.de, netdev@vger.kernel.org, hannes@stressinduktion.org,
	Maxime Bizon <mbizon@freebox.fr>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:38757 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756645AbbEVT0y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 15:26:54 -0400
Content-Disposition: inline
In-Reply-To: <20150522.150310.2248217318352290500.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:

[ cc'd Maxime Bizon ]

> From: Florian Westphal <fw@strlen.de>
> Date: Fri, 22 May 2015 16:32:49 +0200
> 
> > IP (ttl 64, id 12345, offset 0, flags [+, DF], proto UDP (17), length 1204)
> >     192.168.7.1.42 > 10.23.42.2.42: UDP, length 1400
> > IP (ttl 64, id 12345, offset 1184, flags [DF], proto UDP (17), length 244)
> >     192.168.7.1 > 10.23.42.2: ip-proto-17
> 
> I almost consider a fragment with DF set an oxymoron.
> 
> How does this happen?

Good question.  I have no idea why or how this happens.

But it does happen, see e.g. following bug report:
http://marc.info/?l=linux-netdev&m=139870308431986&w=2

Maxime, do you recall what type of traffic generates
the DF-fragments you reported?

Thanks.
