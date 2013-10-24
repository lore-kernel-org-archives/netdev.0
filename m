From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: [PATCH net] net: sched: Don't free f before it is allocated in
 route4_change
Date: Thu, 24 Oct 2013 17:41:57 +0200
Message-ID: <20131024154157.GA4837@cpaasch-mac>
References: <1382626250-15676-1-git-send-email-christoph.paasch@uclouvain.be>
 <1382626473.7572.58.camel@edumazet-glaptop.roam.corp.google.com>
 <20131024145936.GB15936@cpaasch-mac>
 <1382627157.7572.59.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Jing Wang <windsdaemon@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:53298 "EHLO
	smtp6.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753940Ab3JXPmI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 11:42:08 -0400
Content-Disposition: inline
In-Reply-To: <1382627157.7572.59.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24/10/13 - 08:05:57, Eric Dumazet wrote:
> On Thu, 2013-10-24 at 16:59 +0200, Christoph Paasch wrote:
> > On 24/10/13 - 07:54:33, Eric Dumazet wrote:
> 
> > > I see no bug here, you missed the "goto reinsert;"
> > 
> > Ups - sorry...
> > 
> 
> Yeah, trying to find bugs in Alexey code is really tricky ;)

Yeah :)

Instead of the goto, a simple if {} else {} would have made it
more readable IMO.
