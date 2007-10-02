From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: tcp bw in 2.6
Date: Tue, 2 Oct 2007 10:54:23 -0700
Message-ID: <20071002105423.5d61a727@freepuppy.rosehill>
References: <20071002005917.GB5480@bitmover.com>
	<E1IcfN0-0007tt-00@gondolin.me.apana.org.au>
	<20071002150935.GC17418@bitmover.com>
	<20071002154137.GD17418@bitmover.com>
	<4702766E.80202@candelatech.com>
	<20071002171154.GM17418@bitmover.com>
	<47027D80.4070506@candelatech.com>
	<20071002172155.GP17418@bitmover.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>, lm@bitmover.com,
	Herbert Xu <herbert@gondor.apana.org.au>,
	torvalds@linux-foundation.org, davem@davemloft.net,
	wscott@bitmover.com, netdev@vger.kernel.org
To: lm@bitmover.com (Larry McVoy)
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:36355 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753656AbXJBR4H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 13:56:07 -0400
In-Reply-To: <20071002172155.GP17418@bitmover.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2 Oct 2007 10:21:55 -0700
lm@bitmover.com (Larry McVoy) wrote:

> > I'm currently on 2.6.20, and have also tried 10gbe nics on 2.6.23 with
> 
> My guess is that it is a bug in the debian 2.6.18 kernel.
> 
> > Have you tried something like ttcp, iperf, or even regular ftp?
> 
> Yeah, I've factored out the code since BitKeeper, my test program,
> and John's test program all exhibit the same behaviour.  Also switched
> switches.
> 
> > Checked your nics to make sure they have no errors and are negotiated
> > to full duplex?
> 
> Yup and yup.

Make sure you don't have slab debugging turned on. It kills performance.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
