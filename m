From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: [PATCH] PHYLIB: IRQ event workqueue handling fixes
Date: Thu, 18 Oct 2007 12:37:33 +0100 (BST)
Message-ID: <Pine.LNX.4.64N.0710181231350.4701@blysk.ds.pg.gda.pl>
References: <20071015125301.GC3015@ff.dom.local>
 <Pine.LNX.4.64N.0710151737250.16262@blysk.ds.pg.gda.pl> <20071016062108.GB1000@ff.dom.local>
 <Pine.LNX.4.64N.0710161759050.22596@blysk.ds.pg.gda.pl> <20071017085809.GA1658@ff.dom.local>
 <20071018063157.GA1694@ff.dom.local>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andy Fleming <afleming@freescale.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cerber.ds.pg.gda.pl ([153.19.208.18]:44830 "EHLO
	cerber.ds.pg.gda.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755974AbXJRLhl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 07:37:41 -0400
In-Reply-To: <20071018063157.GA1694@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 18 Oct 2007, Jarek Poplawski wrote:

> After rethinking, it looks like this last cancel should be useless.
> So, if phy_interrupt() schedules only if !PHY_HALTED and phy_change()
> does enable_irq() with no exeptions, it seems phy_interrupt() even
> without lock must see PHY_HALTED state before this free_irq() with
> possible DEBUG_SHIRQ call, then maybe only this safety:
> 
> 	WARN_ON(work_pending(&phydev->phy_queue));

 Good point.

  Maciej
