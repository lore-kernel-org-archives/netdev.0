From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: tcp bw in 2.6
Date: Tue, 2 Oct 2007 10:10:55 -0700
Message-ID: <20071002101055.219753cd@freepuppy.rosehill>
References: <20071002005917.GB5480@bitmover.com>
	<E1IcfN0-0007tt-00@gondolin.me.apana.org.au>
	<20071002150935.GC17418@bitmover.com>
	<20071002154137.GD17418@bitmover.com>
	<20071002162534.GG17418@bitmover.com>
	<20071002094726.154fc619@freepuppy.rosehill>
	<20071002164952.GI17418@bitmover.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Larry McVoy <lm@bitmover.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	torvalds@linux-foundation.org, davem@davemloft.net,
	wscott@bitmover.com, netdev@vger.kernel.org
To: lm@bitmover.com (Larry McVoy)
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:37113 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753017AbXJBRMQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 13:12:16 -0400
In-Reply-To: <20071002164952.GI17418@bitmover.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2 Oct 2007 09:49:52 -0700
lm@bitmover.com (Larry McVoy) wrote:

> On Tue, Oct 02, 2007 at 09:47:26AM -0700, Stephen Hemminger wrote:
> > On Tue, 2 Oct 2007 09:25:34 -0700
> > lm@bitmover.com (Larry McVoy) wrote:
> > 
> > > > If the server side is the source of the data, i.e, it's transfer is a 
> > > > write loop, then I get the bad behaviour.  
> > > > ...
> > > > So is this a bug or intentional?
> > > 
> > > For whatever it is worth, I believed that we used to get better performance
> > > from the same hardware.  My guess is that it changed somewhere between
> > > 2.6.15-1-k7 and 2.6.18-5-k7.
> > 
> > For the period from 2.6.15 to 2.6.18, the kernel by default enabled TCP
> > Appropriate Byte Counting. This caused bad performance on applications that
> > did small writes.
> 
> It's doing 1MB writes.
> 
> Is there a sockopt to turn that off?  Or /proc or something?

sysctl -w net.ipv4.tcp_abc=0

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
