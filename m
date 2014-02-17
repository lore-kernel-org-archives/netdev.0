From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH next resend] tcp: use zero-window when free_space is low
Date: Mon, 17 Feb 2014 21:52:19 +0100
Message-ID: <20140217205219.GH31125@breakpoint.cc>
References: <1392292350-28800-1-git-send-email-fw@strlen.de>
 <20140217.143431.349062553619161172.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fw@strlen.de, netdev@vger.kernel.org, ncardwell@google.com,
	eric.dumazet@gmail.com, ycheng@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:50432 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751448AbaBQUwV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 15:52:21 -0500
Content-Disposition: inline
In-Reply-To: <20140217.143431.349062553619161172.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> From: Florian Westphal <fw@strlen.de>
> Date: Thu, 13 Feb 2014 12:52:30 +0100
> 
> >  V1 of this patch was deferred, resending to get discussion going again.
> >  Changes since v1:
> >   - add reproducer to commit message
> > 
> >  Unfortunately I couldn't come up with something that has no magic
> >  ('allowed >> 4') value.  I chose >>4 (1/16th) because it didn't cause
> >  tput limitations in my 'full-mss-sized, steady state' netcat tests.
> > 
> >  Maybe someone has better idea?
> 
> I know this is going to be frustrating, but I've marked this 'deferred'
> again.  Please resubmit after the testing and further discussions have
> been worked out.

Thanks for letting me know.  I understand why you are reluctant to just
apply this.

I will submit another patch shortly that introduces snmp counter for zero-window
(what Eric suggested), perhaps it helps him or others to find a better solution
in the scenario.
