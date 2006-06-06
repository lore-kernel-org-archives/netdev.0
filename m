From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] TCP changes for 2.6.18
Date: Tue, 6 Jun 2006 13:13:53 -0700
Message-ID: <20060606131353.1e55f384@localhost.localdomain>
References: <20060605110331.0f058738@dxpl.pdx.osdl.net>
	<20060605.165859.104035231.davem@davemloft.net>
	<20060606094655.6fd3711f@localhost.localdomain>
	<20060606.122924.99202474.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:56523 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751070AbWFFUN4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2006 16:13:56 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060606.122924.99202474.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 06 Jun 2006 12:29:24 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@osdl.org>
> Date: Tue, 6 Jun 2006 09:46:55 -0700
> 
> > On Mon, 05 Jun 2006 16:58:59 -0700 (PDT)
> > David Miller <davem@davemloft.net> wrote:
> > 
> > > BTW, it seems we now have at least 3 instances "VEGAS + stuff"
> > > and thus the core vegas logic is duplicated that many times.
> > > Would be nice to have some core vegas infrastructure in the
> > > generic congestion avoidance layer at some point.
> > 
> > Agreed, and the vegas stuff needs some work as well. It should
> > have more smoothing like Westwood+
> 
> And that Westwood+ "smoothing" is the same sample smoothing algorithm
> used in other parts of the generic TCP input processing, for example
> in functions such as tcp_rtt_estimator() :-)

We could even support different (or smarter) smoothing functions???
The vegas stuff needs to be smarter that's for sure. Time to go catch up
on my reading.
