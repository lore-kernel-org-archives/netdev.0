From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] Revert "net: Support inclusion of
 <linux/socket.h> before <sys/socket.h>"
Date: Wed, 11 Nov 2009 19:09:24 -0800 (PST)
Message-ID: <20091111.190924.27363037.davem@davemloft.net>
References: <1257991205.2237.73.camel@localhost>
	<20091111.185124.22668587.davem@davemloft.net>
	<1257995115.2237.90.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 538372@bugs.debian.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36648
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760014AbZKLDI6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 22:08:58 -0500
In-Reply-To: <1257995115.2237.90.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Thu, 12 Nov 2009 03:05:15 +0000

> <linux/netlink.h> will not compile for userland, because
> <linux/socket.h> is no longer defining sa_family_t.  For userland, this
> should be defined by <sys/socket.h>.

Still, you still essentially have two choices:

1) Tell userland, sorry you need to include sys/socket.h before
   other "socket stuff" and that means linux/netlink.h in
   particular

2) Put a !__KERNEL__ sys/socket.h include in there, but that's
   asking for trouble.

Ok?
