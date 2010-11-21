From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] e1000: fix screaming IRQ
Date: Sun, 21 Nov 2010 09:54:35 -0800 (PST)
Message-ID: <20101121.095435.193722509.davem@davemloft.net>
References: <20101121104747.17414.88773.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	anupamc@vmware.com, stable@kernel.org, jesse.brandeburg@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33288
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755376Ab0KURyL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Nov 2010 12:54:11 -0500
In-Reply-To: <20101121104747.17414.88773.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sun, 21 Nov 2010 02:48:28 -0800

> From: Anupam Chanda <anupamc@vmware.com>
> 
> VMWare reports that the e1000 driver has a bug when bringing down the
> interface, such that interrupts are not disabled in the hardware but the
> driver stops reporting that it consumed the interrupt.
> 
> The fix is to set the driver's "down" flag later in the routine,
> after all the timers and such have exited, preventing the interrupt
> handler from being called and exiting early without handling the
> interrupt.
> 
> CC: Anupam Chanda <anupamc@vmware.com>
> CC: stable kernel <stable@kernel.org>
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
