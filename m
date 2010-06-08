From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-next-2.6 v2] pkt_sched: gen_estimator: kill
 est_lock rwlock
Date: Tue, 8 Jun 2010 23:18:06 +0200
Message-ID: <20100608211806.GB3496@del.dom.local>
References: <20100608121546.GA9392@ff.dom.local>
 <1276000052.2475.307.camel@edumazet-laptop>
 <20100608124052.GB9392@ff.dom.local>
 <4C0E9A2E.9080109@gmail.com>
 <1276026329.2439.2.camel@edumazet-laptop>
 <20100608202405.GA3496@del.dom.local>
 <1276030354.2439.8.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:15164 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750925Ab0FHVSL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jun 2010 17:18:11 -0400
Received: by fg-out-1718.google.com with SMTP id l26so1600187fgb.1
        for <netdev@vger.kernel.org>; Tue, 08 Jun 2010 14:18:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1276030354.2439.8.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 08, 2010 at 10:52:34PM +0200, Eric Dumazet wrote:
> 
> > Such a changelog is a documentation for future, just like this one,
> > crucial for this suject:
> > http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=0929c2dd83317813425b937fbc0041013b8685ff
> > 
> > There is no reason to make people (our?) life harder with describing
> > unexistent bugs.
> > 
> 
> Now you are telling me there is no bug, and I am lying ?
> 

I didn't question freeing stats_lock (great catch BTW!).

> > > 
> > > I am really lost by your comments Jarek.
> > > 
> > > Maybe you could provide an alternative patch, so that we can make some
> > > progress ?
> > > 
> > 
> > No, I only meant fixing the title and changelog if you have any problem
> > with separating it for two parts.
> 
> I am suggesting you rewrite this Changelog, as being part of the patch,
> since I still miss your point, sorry, I must be very dumb tonight.
> 
> Then, add your Signed-off-by.
> 
> This is normal iterative process.
> 

No understado - no Englisch ;-)

Sorry,
Jarek P.
