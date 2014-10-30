From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH -next 0/2] net: allow setting ecn via routing table
Date: Thu, 30 Oct 2014 23:15:01 +0100
Message-ID: <20141030221501.GA9416@breakpoint.cc>
References: <1414276729-17871-1-git-send-email-fw@strlen.de>
 <20141028.165737.2009356944765978630.davem@davemloft.net>
 <20141029122307.GA29253@breakpoint.cc>
 <20141030.155958.156984068627586090.davem@davemloft.net>
 <20141030205204.GE10069@breakpoint.cc>
 <1414703260.15352.9.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:39793 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934506AbaJ3WPG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 18:15:06 -0400
Content-Disposition: inline
In-Reply-To: <1414703260.15352.9.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2014-10-30 at 21:52 +0100, Florian Westphal wrote:
> 
> > So, what about changing the default to 1 in net-next?
> > 
> > We could add automatic 'no-ecn' to retransmitted syns to avoid
> > ecn blackholes (Daniel Borkmann has a patch for this), and, in case
> > ecn=1 causes too much breakage we can always revert (and re-consider ecn
> > per route settings as an intermediate step).
> > 
> > What do you think?
> 
> I think this is way too dangerous.
> 
> I played a lot with ECN in the past (and fixed number of bugs in linux)
> and discovered many times I had to disable it to be able to surf the
> Internet.
[..]
> Reverting might take a long long time, it wont help people stuck behind
> buggy equipment.

Do you think a fallback to non-ecn for retransmitted syns would help?
If not, do you think having ecn tunable available via route is helpful?

Thanks!
