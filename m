From: David Dillow <dave@thedillows.org>
Subject: Re: [PATCH V2 net-next 14/15] drivers/net/typhoon.c: Use
 (pr|netdev)_<level> macro helpers
Date: Sun, 21 Feb 2010 22:23:15 -0500
Message-ID: <1266808995.2930.24.camel@obelisk.thedillows.org>
References: <1266460221.5719.60.camel@obelisk.thedillows.org>
	 <20100217.184100.232538560.davem@davemloft.net>
	 <1266462064.5719.78.camel@obelisk.thedillows.org>
	 <20100217.191002.240804576.davem@davemloft.net>
	 <1266463341.5719.96.camel@obelisk.thedillows.org>
	 <1266467718.8446.251.camel@Joe-Laptop.home>
	 <1266795829.2930.8.camel@obelisk.thedillows.org>
	 <1266804176.10646.65.camel@Joe-Laptop.home>
	 <1266808127.10646.77.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.knology.net ([24.214.63.101]:45489 "EHLO smtp.knology.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754502Ab0BVDXS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Feb 2010 22:23:18 -0500
In-Reply-To: <1266808127.10646.77.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2010-02-21 at 19:08 -0800, Joe Perches wrote: 
> David Dillow took my suggestions and improved on them.
> Here is this latest version.
> 
> Add #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> Remove #define PFX
> Remove #define ERR_PFX
> Remove now unused member name from struct typhoon
> Use pr_<level>
> Use netdev_<level>
> Coalesce long formats
> Remove version information
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> Signed-off-by: David Dillow <dave@thedillows.org>

Perhaps commit text as follows? I can sign-off on it, but I don't think
my effort rises to that level. I certainly ack the patch, though.

typhoon: clean up message output
    
Use the new netdev_* helpers to clean up and make the logging output
more consistent with other network drivers. This also removes the
constantly-stale version info in favor of using the kernel version from
which the module was built.

Signed-off-by: Joe Perches <joe@perches.com>
Acked-by: David Dillow <dave@thedillows.org>

