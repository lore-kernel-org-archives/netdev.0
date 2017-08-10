From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH v2 net-next 0/7] rtnetlink: allow selected handlers to
 run without rtnl
Date: Thu, 10 Aug 2017 13:29:39 +0200
Message-ID: <20170810112939.GA20558@breakpoint.cc>
References: <20170809184153.16700-1-fw@strlen.de>
 <20170809.172114.233866755819084584.davem@davemloft.net>
 <901d1f86-543b-8225-f87f-e1ab7df3e1a8@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:45728 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751469AbdHJLbw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 07:31:52 -0400
Content-Disposition: inline
In-Reply-To: <901d1f86-543b-8225-f87f-e1ab7df3e1a8@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Ahern <dsahern@gmail.com> wrote:

> On 8/9/17 6:21 PM, David Miller wrote:
> > 
> > Ok series applied, let's see where this goes :-)
> > 
> 
> 1 hour in, 1 problem reported

Its even worse.  Would you rather see a revert?

I'm sure that you are aware that the widespread rtnl usage is a
problem because it does hurt scalability. I still think its worth trying
to disentangle this where possible.

I should have fixes for the reported fallout soon.
Alternatively, I can send a revert plus patch to add ASSERT_RTNL in
one more spot.
