From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] NetLabel: consolidate the struct socket/sock
 handling to just struct sock
Date: Thu, 07 Jun 2007 18:37:21 -0700 (PDT)
Message-ID: <20070607.183721.87999873.davem@davemloft.net>
References: <20070607153226.524778346@hp.com>
	<20070607153607.205559860@hp.com>
	<Line.LNX.4.64.0706072118090.10435@d.namei>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul.moore@hp.com, netdev@vger.kernel.org, selinux@tycho.nsa.gov
To: jmorris@namei.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37820
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1763194AbXFHBhF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2007 21:37:05 -0400
In-Reply-To: <Line.LNX.4.64.0706072118090.10435@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: James Morris <jmorris@namei.org>
Date: Thu, 7 Jun 2007 21:18:26 -0400 (EDT)

> On Thu, 7 Jun 2007, Paul Moore wrote:
> 
> > The current NetLabel code has some redundant APIs which allow both
> > "struct socket" and "struct sock" types to be used; this may have made sense at
> > some point but it is wasteful now.  Remove the functions that operate on
> > sockets and convert the callers.  Not only does this make the code smaller and
> > more consistent but it pushes the locking burden up to the caller which can be
> > more intelligent about the locks.  Also, perform the same conversion (socket
> > to sock) on the SELinux/NetLabel glue code where it make sense.
> > 
> > Signed-off-by: Paul Moore <paul.moore@hp.com>
> 
> Acked-by: James Morris <jmorris@namei.org>

Applied.
