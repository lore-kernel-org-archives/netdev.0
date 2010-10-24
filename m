From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5] netdev: bfin_mac: push settings to platform
 resources
Date: Sun, 24 Oct 2010 16:17:22 -0700 (PDT)
Message-ID: <20101024.161722.258113499.davem@davemloft.net>
References: <1287727161-24671-1-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org,
	sonic.zhang@analog.com
To: vapier@gentoo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53670
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750975Ab0JXXQ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Oct 2010 19:16:59 -0400
In-Reply-To: <1287727161-24671-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Frysinger <vapier@gentoo.org>
Date: Fri, 22 Oct 2010 01:59:17 -0400

> From: Sonic Zhang <sonic.zhang@analog.com>
> 
> Move all the pin settings out of the Kconfig and into the platform
> resources (MII vs RMII).  This clean up also lets us push out the
> phy settings so that board porters may control the layout.
> 
> Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>

You'll have to approach this differently.

The platform specific bfin_mac changes have to be in place
before this change goes in.

Not the other way around.

Right now, in fact, there is only one blackfin board support
file that has the bfin_mii_bus_platform_data bits, but that's
not even going to compile because this patch being discussed
isn't applied.

You guys really have to sort this stuff out so that things
get staged in cleanly and the tree compiles properly commit
to commit.

Thanks.
