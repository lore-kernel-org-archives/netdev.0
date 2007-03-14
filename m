From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [REVISED] net/ipv4/multipath_wrandom.c: check
 kmalloc() return value.
Date: Wed, 14 Mar 2007 15:11:51 -0700 (PDT)
Message-ID: <20070314.151151.75188950.davem@davemloft.net>
References: <Pine.LNX.4.64.0703121411170.13933@sbz-30.cs.Helsinki.FI>
	<20070312.135613.78710501.davem@davemloft.net>
	<20070314201542.GA4192@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: penberg@cs.helsinki.fi, amit2030@gmail.com,
	linux-kernel@vger.kernel.org, akpm@osdl.org,
	netdev@vger.kernel.org, shai@scalex86.org,
	pravin.shelar@calsoftinc.com, benzi@scalemp.com
To: kiran@scalex86.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32887
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752226AbXCNWLy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2007 18:11:54 -0400
In-Reply-To: <20070314201542.GA4192@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ravikiran G Thirumalai <kiran@scalex86.org>
Date: Wed, 14 Mar 2007 13:15:42 -0700

> The kernel bugzilla shows zaroo boogs for multipath cached as well.

Because _EVERYBODY_ turns it off because we tell them to do so!  Every
bug reported to the lists is replied to with "that code is
unbelievably buggy, just turn that off, kthx, bye".  And to reiterate
no distribution turns it on in there kernels, of course there are no
bugs reported in code nobody actually runs.

And it's been that way since day one for this code.

I also want to get rid of this code because it causes major
architectural limitations in the routing code which prevents important
work we want to do in this area.  Even the most skilled core
networking developers don't have the stomache to try and repair
what we have now, and yes they have looked at it and tried.

I'm still very much going to get rid of it, sorry.  It's unrepairable.

My deepest apologies if this inconveniences you personally, but this
is open source and you can always carry a local patch to obtain the
functionality.  In fact, it would be awesome if you took up the
project to rewrite this stuff cleanly from the start, I'd be
absolutely happy to review and integrate such patches.

But for now, what's in there has to go and there is absolutely
no question about it.
