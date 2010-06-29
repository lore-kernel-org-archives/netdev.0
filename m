From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 1/2] 3c59x: Specify window explicitly for
 access to windowed registers
Date: Mon, 28 Jun 2010 23:20:55 -0700 (PDT)
Message-ID: <20100628.232055.15240656.davem@davemloft.net>
References: <1277337161.26161.14.camel@localhost>
	<1277337271.26161.17.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chase.douglas@canonical.com,
	nordmark@mech.kth.se
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47968
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751069Ab0F2GUm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 02:20:42 -0400
In-Reply-To: <1277337271.26161.17.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Thu, 24 Jun 2010 00:54:31 +0100

> Currently much of the code assumes that a specific window has been
> selected, while a few functions save and restore the window.  This
> makes it impossible to introduce fine-grained locking.
> 
> Make those assumptions explicit by introducing wrapper functions
> to set the window and read/write a register.  Use these everywhere
> except vortex_interrupt(), vortex_start_xmit() and vortex_rx().
> These set the window just once, or not at all in the case of
> vortex_rx() as it should always be called from vortex_interrupt().
> 
> Cache the current window in struct vortex_private to avoid
> unnecessary hardware writes.
> 
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> Tested-by: Arne Nordmark <nordmark@mech.kth.se> [against 2.6.32]

Applied.
