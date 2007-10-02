From: John Heffner <jheffner@psc.edu>
Subject: Re: tcp bw in 2.6
Date: Tue, 02 Oct 2007 15:53:26 -0400
Message-ID: <4702A1B6.5020505@psc.edu>
References: <20071002005917.GB5480@bitmover.com> <E1IcfN0-0007tt-00@gondolin.me.apana.org.au> <20071002150935.GC17418@bitmover.com> <47028DEF.5070009@psc.edu> <20071002190742.GC29944@bitmover.com> <20071002193304.GA31611@bitmover.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: lm@bitmover.com, John Heffner <jheffner@psc.edu>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	torvalds@linux-foundation.org, davem@davemloft.net,
	wscott@bitmover.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:58301 "EHLO mailer1.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752588AbXJBTxj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Oct 2007 15:53:39 -0400
In-Reply-To: <20071002193304.GA31611@bitmover.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Larry McVoy wrote:
> More data, we've conclusively eliminated the card / cpu from the mix.
> We've got 2 ia64 boxes with e1000 interfaces.  One box is running
> linux 2.6.12 and the other is running hpux 11.
> 
> I made sure the linux one was running at gigabit and reran the tests
> from the linux/ia64 <=> hp/ia64.  Same results, when linux sends
> it is slow, when it receives it is fast.
> 
> And note carefully: we've removed hpux from the equation, we can do
> the same tests from linux to multiple linux clients and see the same
> thing, sending from the server is slow, receiving on the server is
> fast.


I think I'm still missing some basic data here (probably because this 
thread did not originate on netdev).  Let me try to nail down some of 
the basics.  You have a linux ia64 box (running 2.6.12 or 2.6.18?) that 
sends slowly, and receives faster, but not quite a 1 Gbps?  And this is 
true regardless of which peer it sends or receives from?  And the 
behavior is different depending on which kernel?  How, and which kernel 
versions?  Do you have other hardware running the same kernel that 
behaves the same or differently?

Have you done ethernet cable tests?  Have you tried measuring the udp 
sending rate?  (Iperf can do this.)  Are there any error counters on the 
interface?

   -John
