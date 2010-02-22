From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net-next 14/15] drivers/net/typhoon.c: Use
 (pr|netdev)_<level> macro helpers
Date: Mon, 22 Feb 2010 15:47:11 -0800 (PST)
Message-ID: <20100222.154711.196854108.davem@davemloft.net>
References: <1266795829.2930.8.camel@obelisk.thedillows.org>
	<1266804176.10646.65.camel@Joe-Laptop.home>
	<1266808127.10646.77.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dave@thedillows.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47082
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750766Ab0BVXqx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2010 18:46:53 -0500
In-Reply-To: <1266808127.10646.77.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Sun, 21 Feb 2010 19:08:47 -0800

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

Applied.
