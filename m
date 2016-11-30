From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net-next 2/2] tcp: allow to turn tcp timestamp
 randomization off
Date: Wed, 30 Nov 2016 01:21:11 +0100
Message-ID: <20161130002111.GB6454@breakpoint.cc>
References: <1480434342-12367-1-git-send-email-fw@strlen.de>
 <1480434342-12367-2-git-send-email-fw@strlen.de>
 <1480442832.18162.148.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:44680 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753895AbcK3AYJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 19:24:09 -0500
Content-Disposition: inline
In-Reply-To: <1480442832.18162.148.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2016-11-29 at 16:45 +0100, Florian Westphal wrote:
> > Eric says: "By looking at tcpdump, and TS val of xmit packets of multiple
> > flows, we can deduct the relative qdisc delays (think of fq pacing).
> > This should work even if we have one flow per remote peer."
> > 
> > Having random per flow (or host) offsets doesn't allow that anymore so add
> > a way to turn this off.
> > 
> > Suggested-by: Eric Dumazet <edumazet@google.com>
> > Signed-off-by: Florian Westphal <fw@strlen.de>
> > ---
> 
> Excellent, thanks !
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

Thanks for the ack, I missed connect() side though so this doesn't work
for outgoing connections, sorry :-/

I will send a v2.
