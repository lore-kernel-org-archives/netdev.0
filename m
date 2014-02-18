From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH next resend] tcp: use zero-window when free_space is low
Date: Tue, 18 Feb 2014 09:30:16 -0800
Message-ID: <1392744616.24974.14.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1392292350-28800-1-git-send-email-fw@strlen.de>
	 <20140217.143431.349062553619161172.davem@davemloft.net>
	 <20140217205219.GH31125@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	ncardwell@google.com, ycheng@google.com
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:36515 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751774AbaBRRaR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Feb 2014 12:30:17 -0500
Received: by mail-pd0-f172.google.com with SMTP id p10so16574328pdj.3
        for <netdev@vger.kernel.org>; Tue, 18 Feb 2014 09:30:17 -0800 (PST)
In-Reply-To: <20140217205219.GH31125@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-02-17 at 21:52 +0100, Florian Westphal wrote:
> David Miller <davem@davemloft.net> wrote:
> > From: Florian Westphal <fw@strlen.de>
> > Date: Thu, 13 Feb 2014 12:52:30 +0100
> > 
> > >  V1 of this patch was deferred, resending to get discussion going again.
> > >  Changes since v1:
> > >   - add reproducer to commit message
> > > 
> > >  Unfortunately I couldn't come up with something that has no magic
> > >  ('allowed >> 4') value.  I chose >>4 (1/16th) because it didn't cause
> > >  tput limitations in my 'full-mss-sized, steady state' netcat tests.
> > > 
> > >  Maybe someone has better idea?
> > 
> > I know this is going to be frustrating, but I've marked this 'deferred'
> > again.  Please resubmit after the testing and further discussions have
> > been worked out.
> 
> Thanks for letting me know.  I understand why you are reluctant to just
> apply this.
> 
> I will submit another patch shortly that introduces snmp counter for zero-window
> (what Eric suggested), perhaps it helps him or others to find a better solution
> in the scenario.

Sorry for the delay guys, I was on vacation.

I started the tests this morning, results in about 2/3 hours.

Thanks !
