From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH 1/2][IPV6] addrconf: fix timer deleting on exit
Date: Fri, 6 Jul 2007 07:30:17 +0200
Message-ID: <20070706053017.GA1653@ff.dom.local>
References: <20070705111246.GB1569@ff.dom.local> <20070705.143740.45154350.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	herbert@gondor.apana.org.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:35796 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754715AbXGFFVr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2007 01:21:47 -0400
Content-Disposition: inline
In-Reply-To: <20070705.143740.45154350.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 05, 2007 at 02:37:40PM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2@o2.pl>
> Date: Thu, 5 Jul 2007 13:12:46 +0200
> 
> > 
> > It looks like a timer function can be running and rearm
> > the timer after removing a ipv6 module.
> > 
> > Signed-off-by: Jarek Poplawski <jarkao2@o2.pl>
> 
> This is completely academic as ipv6 as a module cannot
> be removed, and it's been that way for years :-)
> 

Very nice! This is what I've always dreamed about:
pure programming without any practical usability.

My other big dream is that some beautiful day linux
will have separate arch for this, e.g. pure64...

Thanks,
Jarek P.
