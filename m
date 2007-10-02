From: lm@bitmover.com (Larry McVoy)
Subject: Re: tcp bw in 2.6
Date: Tue, 2 Oct 2007 09:49:52 -0700
Message-ID: <20071002164952.GI17418@bitmover.com>
References: <20071002005917.GB5480@bitmover.com> <E1IcfN0-0007tt-00@gondolin.me.apana.org.au> <20071002150935.GC17418@bitmover.com> <20071002154137.GD17418@bitmover.com> <20071002162534.GG17418@bitmover.com> <20071002094726.154fc619@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Larry McVoy <lm@bitmover.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	torvalds@linux-foundation.org, davem@davemloft.net,
	wscott@bitmover.com, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ipcop.bitmover.com ([192.132.92.15]:43475 "EHLO
	mail.bitmover.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752775AbXJBQtx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 12:49:53 -0400
Content-Disposition: inline
In-Reply-To: <20071002094726.154fc619@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 02, 2007 at 09:47:26AM -0700, Stephen Hemminger wrote:
> On Tue, 2 Oct 2007 09:25:34 -0700
> lm@bitmover.com (Larry McVoy) wrote:
> 
> > > If the server side is the source of the data, i.e, it's transfer is a 
> > > write loop, then I get the bad behaviour.  
> > > ...
> > > So is this a bug or intentional?
> > 
> > For whatever it is worth, I believed that we used to get better performance
> > from the same hardware.  My guess is that it changed somewhere between
> > 2.6.15-1-k7 and 2.6.18-5-k7.
> 
> For the period from 2.6.15 to 2.6.18, the kernel by default enabled TCP
> Appropriate Byte Counting. This caused bad performance on applications that
> did small writes.

It's doing 1MB writes.

Is there a sockopt to turn that off?  Or /proc or something?
-- 
---
Larry McVoy                lm at bitmover.com           http://www.bitkeeper.com
