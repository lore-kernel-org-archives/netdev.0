From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/3] ne: Add platform_driver
Date: Sat, 28 Apr 2007 11:07:26 -0400
Message-ID: <4633632E.5030607@garzik.org>
References: <20070425.015450.25909765.anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, netdev@vger.kernel.org,
	ralf@linux-mips.org, sshtylyov@ru.mvista.com,
	akpm@linux-foundation.org
To: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:51946 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751306AbXD1PHg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Apr 2007 11:07:36 -0400
In-Reply-To: <20070425.015450.25909765.anemo@mba.ocn.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Atsushi Nemoto wrote:
> * Add platform_driver interface to ne driver.
>   (Existing legacy ports did not covered by this ne_driver for now)
> * Make ioaddr 'unsigned long'.
> * Move a printk down to show dev->name assigned in register_netdev.


Please split this patch into two patches: one patch does platform_driver 
conversion, and the other patch is the other two items you describe above.

