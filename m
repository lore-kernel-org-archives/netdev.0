From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] declance: Remove a dangling spin_unlock_irq() thingy
Date: Mon, 21 May 2007 19:42:14 -0400
Message-ID: <46522E56.2050606@garzik.org>
References: <Pine.LNX.4.64N.0705211414540.8263@blysk.ds.pg.gda.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org
To: "Maciej W. Rozycki" <macro@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46417 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757417AbXEUXmS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 May 2007 19:42:18 -0400
In-Reply-To: <Pine.LNX.4.64N.0705211414540.8263@blysk.ds.pg.gda.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Maciej W. Rozycki wrote:
>  The spin_unlock_irq() invocation in lance_start_xmit() has no matching 
> locking request.  The call is already protected by netif_tx_lock, so 
> remove the statement.
> 
> Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>

applied


