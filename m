From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 9750] [patch 2.6.25] dev: avoid a race that triggers
 assertion failure
Date: Tue, 12 Feb 2008 18:16:16 -0800 (PST)
Message-ID: <20080212.181616.181583250.davem@davemloft.net>
References: <190693.34289.qm@web52005.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	bugme-daemon@kernel-bugs.osdl.org
To: mattilinnanvuori@yahoo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59711
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753735AbYBMCPo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2008 21:15:44 -0500
In-Reply-To: <190693.34289.qm@web52005.mail.re2.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matti Linnanvuori <mattilinnanvuori@yahoo.com>
Date: Tue, 12 Feb 2008 02:45:22 -0800 (PST)

> From: Matti Linnanvuori <mattilinnanvuori@yahoo.com>
> 
> There is a race in Linux kernel file net/core/dev.c, function dev_close.
> The function calls function dev_deactivate, which calls function
> dev_watchdog_down that deletes the watchdog timer. However, after that, a
> driver can call netif_carrier_ok, which calls function
> __netdev_watchdog_up that can add the watchdog timer again. Function
> unregister_netdevice calls function dev_shutdown that traps the bug
> !timer_pending(&dev->watchdog_timer). Moving dev_deactivate after
> netif_running() has been cleared prevents function netif_carrier_on
> from calling __netdev_watchdog_up and adding the watchdog timer again.
> 
> Signed-off-by: Matti Linnanvuori <mattilinnanvuori@yahoo.com>

Your patch won't apply because it has been whitespace damanged
by your email client.

This is what I let you know last time you posted this patch.

Please fix this up so that your patch can be applied.

Thanks.
