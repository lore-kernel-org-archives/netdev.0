From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 18/19] mv643xx ethernet driver IRQ registration fix
Date: Tue, 06 Mar 2007 06:16:43 -0500
Message-ID: <45ED4D9B.9090100@garzik.org>
References: <200703061042.l26Ag25d019787@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, giri@lmc.cs.sunysb.edu,
	dale@farnsworth.org, pgiri@yahoo.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53298 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965854AbXCFLQp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 06:16:45 -0500
In-Reply-To: <200703061042.l26Ag25d019787@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@linux-foundation.org wrote:
> From: Giridhar Pemmasani <giri@lmc.cs.sunysb.edu>
> 
> During initialization, mv643xx driver registers IRQ before setting up tx/rx
> rings.  This causes kernel oops because mv643xx_poll, which gets called
> right after registering IRQ, calls netif_rx_complete, which accesses the rx
> ring (I don't have the oops message anymore; I just remember this sequence
> of calls).  Attached (tested) patch first initializes the rx/tx rings and
> then registers the IRQ.
> 
> Signed-off-by: Giridhar Pemmasani <pgiri@yahoo.com>
> Cc: Dale Farnsworth <dale@farnsworth.org>
> Cc: Jeff Garzik <jeff@garzik.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/mv643xx_eth.c |   40 +++++++++++++++++++-----------------
>  1 file changed, 22 insertions(+), 18 deletions(-)

seems sane enough to me, but I would like to get this via Dale, who has 
been a fairly active maintainer so far


