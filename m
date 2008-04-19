From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] net: add destructor for skb data (rewritten)
Date: Sun, 20 Apr 2008 01:49:15 +1000
Message-ID: <200804200149.16345.rusty@rustcorp.com.au>
References: <200804181421.25828.rusty@rustcorp.com.au> <20080419094600.GA11682@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Max Krasnyansky <maxk@qualcomm.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:42985 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752994AbYDSPtw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Apr 2008 11:49:52 -0400
In-Reply-To: <20080419094600.GA11682@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 19 April 2008 19:46:01 Evgeniy Polyakov wrote:
> On Fri, Apr 18, 2008 at 02:21:25PM +1000, Rusty Russell 
(rusty@rustcorp.com.au) wrote:
> > If we want to notify something when an skb is truly finished (such as
> > for tun vringfd support), we need a destructor on the data.
>
> Can we put its invokation before pages are freed?

Sure.  I don't need that, but it's easy to change.

Cheers,
Rusty.
