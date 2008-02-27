From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH (resend)] Don't create tunnels with '%' in name.
Date: Tue, 26 Feb 2008 23:51:47 -0800 (PST)
Message-ID: <20080226.235147.262588180.davem@davemloft.net>
References: <47C514E1.3090800@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50922
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750919AbYB0Hvs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2008 02:51:48 -0500
In-Reply-To: <47C514E1.3090800@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Wed, 27 Feb 2008 10:44:33 +0300

> Four tunnel drivers (ip_gre, ipip, ip6_tunnel and sit) can
> receive a pre-defined name for a device from the userspace.
> Since these drivers call the register_netdevice() (rtnl_lock,
> is held), which does _not_ generate the device's name, this 
> name may contain a '%' character.
> 
> Not sure how bad is this to have a device with a '%' in its
> name, but all the other places either use the register_netdev(),
> which call the dev_alloc_name(), or explicitly call the 
> dev_alloc_name() before registering, i.e. do not allow for 
> such names.
> 
> This had to be prior to the commit 34cc7b, but I forgot to
> number the patches and this one got lost, sorry.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied, thanks Pavel.

I've already sent a pull request to Linus an hour ago, so
this will get in next time around.
