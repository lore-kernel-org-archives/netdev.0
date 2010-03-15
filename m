From: David Miller <davem@davemloft.net>
Subject: Re: net-2.6 [Bug-Fix][dccp]: fix oops caused after failed
 initialisation
Date: Mon, 15 Mar 2010 16:07:04 -0700 (PDT)
Message-ID: <20100315.160704.112076366.davem@davemloft.net>
References: <20100315061318.GA6110@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@redhat.com, netdev@vger.kernel.org, dccp@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42750
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S937102Ab0COXGm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Mar 2010 19:06:42 -0400
In-Reply-To: <20100315061318.GA6110@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 15 Mar 2010 07:13:19 +0100

> dccp: fix panic caused by failed initialisation
> 
> This fixes a kernel panic reported thanks to Andre Noll:
> 
> if DCCP is compiled into the kernel and any out of the initialisation
> steps in net/dccp/proto.c:dccp_init() fail, a subsequent attempt to create
> a SOCK_DCCP socket will panic, since inet{,6}_create() are not prevented
> from creating DCCP sockets.
> 
> This patch fixes the problem by propagating a failure in dccp_init() to
> dccp_v{4,6}_init_net(), and from there to dccp_v{4,6}_init(), so that the
> DCCP protocol is not made available if its initialisation fails.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Applied, thanks Gerrit.
