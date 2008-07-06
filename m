From: David Miller <davem@davemloft.net>
Subject: Re: [udplite] [Patch 1/1] [BUG-FIX]: Avoid u16 checksum coverage
 wrap-around
Date: Sat, 05 Jul 2008 23:36:41 -0700 (PDT)
Message-ID: <20080705.233641.190712838.davem@davemloft.net>
References: <20080703113141.GA8223@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51291
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751436AbYGFGgm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jul 2008 02:36:42 -0400
In-Reply-To: <20080703113141.GA8223@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 3 Jul 2008 12:31:41 +0100

> udplite: Protection against coverage value wrap-around
> 
> This protects UDP-Lite against illegal checksum coverage values and
> against illegal checksum coverage values caused by the `int' argument
> wrapping around at 0xffff.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Please preserve the current of using the default value of "8" when an
illegal value is specified.  This behavior might be important and
specified somewhere, such as the BSD socket API for udplite used on
other systems.  The fact that it's even explicitly mentioned in the
documentation file is a strong indication that it might be that way
for a good reason.

Also, even if we should change the behvaior, it's a seperate change
from correcting the test.

Gerrit, you like to mix up multiple things at the same time and it
makes your stuff harder to review.  It also, as a result, makes it
take longer to integrate your work.
