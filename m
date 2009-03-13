From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Assign linklocal addresses to isatap from link dev
Date: Fri, 13 Mar 2009 14:43:41 -0700 (PDT)
Message-ID: <20090313.144341.117676496.davem@davemloft.net>
References: <200903010134.54405.mail@saschahlusiak.de>
	<20090304.032835.183524465.davem@davemloft.net>
	<200903041849.48474.mail@saschahlusiak.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fred.l.templin@boeing.com
To: mail@saschahlusiak.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46528
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752838AbZCMVnz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 17:43:55 -0400
In-Reply-To: <200903041849.48474.mail@saschahlusiak.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sascha Hlusiak <mail@saschahlusiak.de>
Date: Wed, 4 Mar 2009 18:49:41 +0100

> > > That way stateless autoconf works with isatap tunnels and without
> > > knowledge of the local v4 address.
> >
> > Real autoconf is not performed, but rather you must configure your
> > system with a PRL (potential routers list) and these routers are
> > probed periodically in order to keep track of which of them are still
> > functioning and also to perform a sort-of unicast-only autoconf.
> Well, since ISATAP is just a SIT, it still needs a link local address for 
> autoconf and it needs to have it's v4 Address embedded in the lowest 32 bit of 
> the linklocal address. It will then do normal autoconf with the potential 
> router by sending a proper router solicitation messages, either directed or 
> multicast.
> 
> I see that the current implementation disables sending of RS when on ISATAP, 
> which is not correct because RS are needed to do the autoconf.
> 
> At least that's the way the implementation in MS Windows works.
> 
> > I am pretty sure that the person who added the ISATAP code created the
> > current behavior intentionally.
> Well, the current implementation does not cover clients at all, because 
> the ip command refuses to create tunnels without the remote parameter, which 
> is neccessary because it's the potential router.
> 
> It then does not derive the linklocal address correctly, making it impossible 
> to do autoconf with the server. Using SIT does work as such as you still need 
> to add the correct ISATAP linklocal address to the interface. 
> 
> I think ISATAP Client support in Linux could be more automated.

Let's ask the ISATAP author the intent of the situation.
CC:'d

Fred?
