From: Florian Westphal <fw@strlen.de>
Subject: Re: cgroup matches in INPUT chain
Date: Fri, 20 Mar 2015 17:11:11 +0100
Message-ID: <20150320161111.GA11498@breakpoint.cc>
References: <550B1852.2020209@zonque.org>
 <20150319185807.GA3845@breakpoint.cc>
 <550C2753.9020608@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>,
	Alexey Perevalov <a.perevalov@samsung.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	netdev <netdev@vger.kernel.org>
To: Daniel Mack <daniel@zonque.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:45675 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750916AbbCTQLT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 12:11:19 -0400
Content-Disposition: inline
In-Reply-To: <550C2753.9020608@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Mack <daniel@zonque.org> wrote:
> On 03/19/2015 07:58 PM, Florian Westphal wrote:
> > Daniel Mack <daniel@zonque.org> wrote:
> >> In my tests, however, NF_INET_LOCAL_IN is iterated before early_demux()
> >> is called,
> > 
> > Early demux occurs after PRE_ROUTING but before LOCAL_IN.
> 
> Hmm, you're right, except it isn't in my case. I'm not familiar with
> that code, so please bear with me :)
> 
> In my simple test setup, when skbs are dequeued by process_backlog(),
> they have skb->_skb_refdst set, and hence ip_rcv_finish() does not call
> into early_demux() prior to iterating the INPUT chain:

Yes, because we already have a route set.

Are we talking about loopback?
What are you trying to do?
