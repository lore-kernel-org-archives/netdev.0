From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: cpu utilisation improvement when not doing netif_tx_{stop,wake}_queue()
Date: Fri, 29 Aug 2008 16:46:52 +0200
Message-ID: <20080829144652.GB1290@xi.wantstofly.org>
References: <20080828164638.GA25919@xi.wantstofly.org> <E1KYyCW-00025D-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, dale@farnsworth.org,
	nico@cam.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:48062 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751456AbYH2Oqy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2008 10:46:54 -0400
Content-Disposition: inline
In-Reply-To: <E1KYyCW-00025D-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 29, 2008 at 05:15:20PM +1000, Herbert Xu wrote:

> > I.e. transmitting wire speed gigabit over a single TCP session takes
> > around 90% CPU time (measured with cyclesoak) if I have the TX queue
> > flow control enabled, but only 70% if I rip the TX queue flow control
> > out.  (This is on a relatively underpowered ARM box.)
> 
> How many cores and how many queues?

One core (at 1.0GHz), and one queue in use at the moment.
