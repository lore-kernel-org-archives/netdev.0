From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] netdev: mv643xx_eth: Prevent build on PPC32
Date: Wed, 6 Jun 2012 07:29:10 +0200
Message-ID: <20120606052910.GA674@lunn.ch>
References: <20120605192820.GC7683@zod.bos.redhat.com>
 <1338939005.21665.54.camel@deadeye.wl.decadent.org.uk>
 <20120606023842.GD7683@zod.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <ben@decadent.org.uk>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Andrew Lunn <andrew@lunn.ch>, Olof Johansson <olof@lixom.net>,
	netdev@vger.kernel.org
To: Josh Boyer <jwboyer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from londo.lunn.ch ([80.238.139.98]:58907 "EHLO londo.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754105Ab2FFF3W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jun 2012 01:29:22 -0400
Content-Disposition: inline
In-Reply-To: <20120606023842.GD7683@zod.bos.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The proper fix, from my minimal looking, was one of:
> 
> 1) revert the change for ARM that introduced th clk stuff
> 2) do a similar change as the original commit but with a bunch of
> #ifdef-ery
> 3) implement the clkdev API stuff for 32-bit ppc
> 
> Honestly, I'd go for either 1 or 2.  The commit that introduced it was
> broken to begin with, but that isn't my call.

I broke it. Sorry.

At the time, there was a push to remove all the #ifdefs. The following
patchset was doing this:

https://lkml.org/lkml/2012/4/21/94

it would provide dummy implementations for those systems without clk
support. However, it seems that patch set never made it in, and i did
not declare my dependency on it.

I'm happy to add #ifdef. However, i would first like to understand
what was 'broken to begin with'.

     Thanks
	Andrew
