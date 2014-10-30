From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH -next 0/2] net: allow setting ecn via routing table
Date: Fri, 31 Oct 2014 00:16:37 +0100
Message-ID: <20141030231637.GF10069@breakpoint.cc>
References: <1414276729-17871-1-git-send-email-fw@strlen.de>
 <20141028.165737.2009356944765978630.davem@davemloft.net>
 <20141029122307.GA29253@breakpoint.cc>
 <20141030.155958.156984068627586090.davem@davemloft.net>
 <20141030205204.GE10069@breakpoint.cc>
 <1414703260.15352.9.camel@edumazet-glaptop2.roam.corp.google.com>
 <20141030221501.GA9416@breakpoint.cc>
 <1414710342.15352.14.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:39876 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1161432AbaJ3XQk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 19:16:40 -0400
Content-Disposition: inline
In-Reply-To: <1414710342.15352.14.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2014-10-30 at 23:15 +0100, Florian Westphal wrote:
> 
> > Do you think a fallback to non-ecn for retransmitted syns would help?
> 
> Unfortunately some firewalls are buggy and accept a single SYN per flow.
[..]
> Note that ECN problems are not only contained in SYN packets being
> eventually dropped. You might have a success to establish a flow, and
> later get CE marks for all packets and cwnd converges to 1.

I see. So that makes ecn=1 default a pure fantasy.

Thanks for explaining this.
