From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH take 2] pkt_sched: Fix qdisc_watchdog() vs.
 dev_deactivate() race
Date: Sat, 20 Sep 2008 00:28:10 -0700 (PDT)
Message-ID: <20080920.002810.254219584.davem@davemloft.net>
References: <20080914202715.GA2540@ami.dom.local>
	<20080920.002137.108837580.davem@davemloft.net>
	<20080920072542.GA457@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, netdev@vger.kernel.org, kaber@trash.net
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47994
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750736AbYITH2W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2008 03:28:22 -0400
In-Reply-To: <20080920072542.GA457@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 20 Sep 2008 16:25:42 +0900

> On Sat, Sep 20, 2008 at 12:21:37AM -0700, David Miller wrote:
> >
> > The cpu utilization savings exist for case #1 only, and we can
> > implement the bypass logic _perfectly_ as described above.
> > 
> > For #2 there is nothing to check, just do it and see what comes
> > out of the qdisc.
> 
> Your analysis sounds perfect to me.  And I'm sure happy to see
> this thread die as it's starting to take up a significant amount
> of space in my mailbox :)

It's not really dead until someone writes a patch :-)
