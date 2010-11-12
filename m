From: Simon Horman <horms@verge.net.au>
Subject: Re: can-bcm: fix minor heap overflow
Date: Fri, 12 Nov 2010 11:48:05 +0900
Message-ID: <20101112024805.GC24958@verge.net.au>
References: <4CDB1856.4040001@hartkopp.net>
 <20101112023950.GA8145@verge.net.au>
 <1289529838.3090.209.camel@Dan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Oliver Hartkopp <socketcan@hartkopp.net>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Urs Thuermann <urs@isnogud.escape.de>, security@kernel.org
To: Dan Rosenberg <drosenberg@vsecurity.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:59803 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753962Ab0KLCsJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 21:48:09 -0500
Content-Disposition: inline
In-Reply-To: <1289529838.3090.209.camel@Dan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 11, 2010 at 09:43:58PM -0500, Dan Rosenberg wrote:
> 
> > 
> > If the string may be up to 17 bytes long why are you allocating 20?
> > 
> 
> In Oliver's defense, this doesn't matter even a little bit.  The
> structure will be allocated with kmalloc-1024 either way.

I agree that its very unlikely to make any difference.
I am just curious.
