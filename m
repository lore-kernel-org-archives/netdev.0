From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 1/2] NetLabel: consolidate the struct socket/sock handling
 to just struct sock
Date: Thu, 7 Jun 2007 21:18:26 -0400 (EDT)
Message-ID: <Line.LNX.4.64.0706072118090.10435@d.namei>
References: <20070607153226.524778346@hp.com> <20070607153607.205559860@hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov
To: Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail5.sea5.speakeasy.net ([69.17.117.7]:54295 "EHLO
	mail5.sea5.speakeasy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932215AbXFHBSa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2007 21:18:30 -0400
In-Reply-To: <20070607153607.205559860@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 7 Jun 2007, Paul Moore wrote:

> The current NetLabel code has some redundant APIs which allow both
> "struct socket" and "struct sock" types to be used; this may have made sense at
> some point but it is wasteful now.  Remove the functions that operate on
> sockets and convert the callers.  Not only does this make the code smaller and
> more consistent but it pushes the locking burden up to the caller which can be
> more intelligent about the locks.  Also, perform the same conversion (socket
> to sock) on the SELinux/NetLabel glue code where it make sense.
> 
> Signed-off-by: Paul Moore <paul.moore@hp.com>

Acked-by: James Morris <jmorris@namei.org>

