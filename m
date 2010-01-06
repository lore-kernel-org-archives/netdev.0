From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: BSD 4.2 style TCP keepalives
Date: Wed, 6 Jan 2010 15:50:55 -0500
Message-ID: <20100106205055.GA11620@hmsreliant.think-freely.org>
References: <20100105.163911.10233438.davem@davemloft.net>
 <20100106020756.GA4378@localhost.localdomain>
 <20100105.195953.16499086.davem@davemloft.net>
 <4B44C6AD.6040806@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	ilpo.jarvinen@helsinki.fi
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:52847 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755430Ab0AFUvE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2010 15:51:04 -0500
Content-Disposition: inline
In-Reply-To: <4B44C6AD.6040806@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 06, 2010 at 09:21:49AM -0800, Rick Jones wrote:
> David Miller wrote:
> >From: Neil Horman <nhorman@tuxdriver.com>
> >Date: Tue, 5 Jan 2010 21:07:56 -0500
> >
> >
> >>Dave, If that patch fixes the problem (waiting on test results now,
> >>but I figure it will), what if we add a parameter to tcp_sequence
> >>(and tcp_validate_incomming), that represents an offset to trim from
> >>end_seq (so that we can effectively ignore the garbage byte)?
> >
> >
> >Sure, we could do that too, and it would be an improvement.
> >
> >Let's first wait for test results and also give a bit for
> >others to potentially come up with implementation ideas.
> 
> Might it suffice to simply enable TCP keepalives on the Linux end?
> Or is that too big a kludge?
> 
I imagine that would prevent the consequences of the problem (which is that,
after not responding to several of these older keep-alives, the connection gets
reset), but doing so requires that we know the keepalive interval configured on
the peer, and we don't normally know that.  What we need to do here is be able
to respond to these old keep alives (arguably)

Neil

> rick jones
> 
