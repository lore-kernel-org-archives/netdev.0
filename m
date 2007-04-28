From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: Re: [PATCH 1/3] ne: Add platform_driver
Date: Sun, 29 Apr 2007 02:12:52 +0900 (JST)
Message-ID: <20070429.021252.75203789.anemo@mba.ocn.ne.jp>
References: <20070425.015450.25909765.anemo@mba.ocn.ne.jp>
	<4633632E.5030607@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, netdev@vger.kernel.org,
	ralf@linux-mips.org, sshtylyov@ru.mvista.com,
	akpm@linux-foundation.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mba.ocn.ne.jp ([122.1.175.29]:55925 "EHLO smtp.mba.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756480AbXD1RMv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Apr 2007 13:12:51 -0400
In-Reply-To: <4633632E.5030607@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 28 Apr 2007 11:07:26 -0400, Jeff Garzik <jeff@garzik.org> wrote:
> > * Add platform_driver interface to ne driver.
> >   (Existing legacy ports did not covered by this ne_driver for now)
> > * Make ioaddr 'unsigned long'.
> > * Move a printk down to show dev->name assigned in register_netdev.
> 
> Please split this patch into two patches: one patch does platform_driver 
> conversion, and the other patch is the other two items you describe above.

OK, I'll update and split the patch.  Thank you.

---
Atsushi Nemoto
