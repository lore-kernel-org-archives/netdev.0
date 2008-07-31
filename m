From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: using software TSO on non-TSO capable netdevices
Date: Thu, 31 Jul 2008 12:14:25 +0200
Message-ID: <20080731101425.GE23814@xi.wantstofly.org>
References: <20080731004123.GB22826@xi.wantstofly.org> <E1KONuu-00017h-00@gondolin.me.apana.org.au> <20080731023652.GA23814@xi.wantstofly.org> <20080731030339.GA4327@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, akarkare@marvell.com,
	nico@cam.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:54340 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750887AbYGaKO1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2008 06:14:27 -0400
Content-Disposition: inline
In-Reply-To: <20080731030339.GA4327@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 31, 2008 at 11:03:39AM +0800, Herbert Xu wrote:

> > The maximum that splice will allow -- PIPE_BUFFERS * PAGE_SIZE.
> > 
> > I.e. the writes should be large enough.
> 
> Have you looked at the packet dump? Maybe it was being constrained
> by the receiver/congestion windows.

The receiver seems to advertise a large enough window (700-ish KiB,
while the RTT is ~ 0.1 ms).  As to the congestion window, I had the
idea that it's not increasing beyond ~2-3 because the RTT is so low so
it doesn't need much data to fill the pipe, but I'm not a TCP expert.

I've put a tcpdump taken on the receiving end (192.168.42.10) here:

	http://www.wantstofly.org/~buytenh/dump.bz2

I'll be happy to try other things. :-)
