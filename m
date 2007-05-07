From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH revised 10/11][TG3]: Eliminate spurious interrupts.
Date: Mon, 07 May 2007 00:26:54 -0700 (PDT)
Message-ID: <20070507.002654.130240149.davem@davemloft.net>
References: <1551EAE59135BE47B544934E30FC4FC0940105@nt-irva-0751.brcm.ad.broadcom.com>
	<20070504.204700.24899658.davem@davemloft.net>
	<1178410771.4859.50.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58126
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754089AbXEGH0v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 May 2007 03:26:51 -0400
In-Reply-To: <1178410771.4859.50.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Sat, 05 May 2007 17:19:31 -0700

> [TG3]: Eliminate spurious interrupts.
> 
> Spurious interrupts are often encountered especially on systems
> using the 8259 PIC mode.  This is because the I/O write to deassert
> the interrupt is posted and won't get to the chip immediately.  As
> a result, the IRQ may remain asserted after the IRQ handler exits,
> causing spurious interrupts.
> 
> Flush the interrupt mailbox in non-MSI handlers to de-assert the
> IRQ immediately.  This seems to be the most straight forward approach
> after discussion with Jeff Garzik and David Miller.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
