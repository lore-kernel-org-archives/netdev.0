From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 10/11][TG3]: Reduce spurious interrupts.
Date: Fri, 04 May 2007 20:47:00 -0700 (PDT)
Message-ID: <20070504.204700.24899658.davem@davemloft.net>
References: <20070504.194207.82054727.davem@davemloft.net>
	<1551EAE59135BE47B544934E30FC4FC0940105@nt-irva-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38726
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1423976AbXEEDq7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2007 23:46:59 -0400
In-Reply-To: <1551EAE59135BE47B544934E30FC4FC0940105@nt-irva-0751.brcm.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Fri, 4 May 2007 19:50:10 -0700

> In a small number of cases, we really get a ton of spurious interrupts.
> We have even seen the kernel shutting off IRQ7 because of too many
> unclaimed spurious interrupts.

Ok, that's a big problem.

In retrospect the read back is only needed on non-MSI
right?  I guess that'd be ok.
