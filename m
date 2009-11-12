From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] Revert "net: Support inclusion of
 <linux/socket.h> before <sys/socket.h>"
Date: Wed, 11 Nov 2009 18:51:24 -0800 (PST)
Message-ID: <20091111.185124.22668587.davem@davemloft.net>
References: <1257991205.2237.73.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 538372@bugs.debian.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50095
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758345AbZKLCu5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 21:50:57 -0500
In-Reply-To: <1257991205.2237.73.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Thu, 12 Nov 2009 02:00:05 +0000

> This reverts commit 9c501935a3cdcf6b1d35aaee3aa11c7a7051a305.  That
> commit caused <linux/rtnetlink.h> to require that <sys/socket.h> is
> included first, breaking autoconf tests for <linux/rtnetlink.h> and
> presumably some real programs too.
> 
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>

I'm not reverting this Ben.  The dependency those programs and
autoconf tests have is _dubious_ at best.

It means they were depending upon the libc5 checks passing, that's
rediculious and not something we should cater to.

If you really want it to work that linux/rtnetlink.h is included first
before sys/socket.h in userland, fix that specifically instead.  But
I believe such a dependency is reasonable and the userspace bits need
fixing.

