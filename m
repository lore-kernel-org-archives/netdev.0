From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next resend] tcp: use zero-window when free_space is low
Date: Wed, 19 Feb 2014 16:36:51 -0500 (EST)
Message-ID: <20140219.163651.1448300228306057162.davem@davemloft.net>
References: <20140217205219.GH31125@breakpoint.cc>
	<1392744616.24974.14.camel@edumazet-glaptop2.roam.corp.google.com>
	<1392765133.18849.0.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, netdev@vger.kernel.org, ncardwell@google.com,
	ycheng@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46989 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752516AbaBSVgx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Feb 2014 16:36:53 -0500
In-Reply-To: <1392765133.18849.0.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 18 Feb 2014 15:12:13 -0800

> On Tue, 2014-02-18 at 09:30 -0800, Eric Dumazet wrote:
>> On Mon, 2014-02-17 at 21:52 +0100, Florian Westphal wrote:
>> > David Miller <davem@davemloft.net> wrote:
>> > > From: Florian Westphal <fw@strlen.de>
>> > > Date: Thu, 13 Feb 2014 12:52:30 +0100
>> > > 
>> > > >  V1 of this patch was deferred, resending to get discussion going again.
>> > > >  Changes since v1:
>> > > >   - add reproducer to commit message
>> > > > 
>> > > >  Unfortunately I couldn't come up with something that has no magic
>> > > >  ('allowed >> 4') value.  I chose >>4 (1/16th) because it didn't cause
>> > > >  tput limitations in my 'full-mss-sized, steady state' netcat tests.
>> > > > 
>> > > >  Maybe someone has better idea?
>> > > 
>> > > I know this is going to be frustrating, but I've marked this 'deferred'
>> > > again.  Please resubmit after the testing and further discussions have
>> > > been worked out.
>> > 
>> > Thanks for letting me know.  I understand why you are reluctant to just
>> > apply this.
>> > 
>> > I will submit another patch shortly that introduces snmp counter for zero-window
>> > (what Eric suggested), perhaps it helps him or others to find a better solution
>> > in the scenario.
>> 
>> Sorry for the delay guys, I was on vacation.
>> 
>> I started the tests this morning, results in about 2/3 hours.
> 
> No regression found, feel free to add my :
> 
> Acked-by: Eric Dumazet <edumazet@google.com>
> Tested-by: Eric Dumazet <edumazet@google.com>

Florian please resend with Eric's tags and I'll apply.
