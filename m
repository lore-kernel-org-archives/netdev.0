From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] niu.c: Use pr_<level>, netdev_<level> and
 netif_<level> macros
Date: Sun, 14 Feb 2010 22:41:08 -0800 (PST)
Message-ID: <20100214.224108.51485961.davem@davemloft.net>
References: <cover.1265751023.git.joe@perches.com>
	<20100212.123129.163263355.davem@davemloft.net>
	<1266194829.16721.940.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32994
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752064Ab0BOGkx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2010 01:40:53 -0500
In-Reply-To: <1266194829.16721.940.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Sun, 14 Feb 2010 16:47:09 -0800

> OK David, here you go.
> 
> I'm not sure of the conversions of:
> 	dev_<level>(np->device,...
> to
> 	netdev_<level>(np->dev,...
> 
> It compiles, but dunno if it's correct (no hw to test)
> 
> Remove #define PFX
> Add pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> Convert printks to pr_<level>
> Convert printks without levels to pr_cont
> Convert pr_<level> with np->dev to netdev_<level>
> Convert dev_<level> to netdev_<level>
> Convert niudbg to netif_printk
> Convert niuinfo, niuwarn macros to netif_<level>(priv, type, dev...
> Coalesce long formats
> Convert embedded function names to "%s", __func__
> Always use "%s()..." when __func__ is printed
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Thanks Joe.

It looks good here and I'll give it a quick test before
doing a final push of this into net-next-2.6

Thanks!
