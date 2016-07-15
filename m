From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: ethernet: amd: au1000_eth: use
 phy_ethtool_{get|set}_link_ksettings
Date: Fri, 15 Jul 2016 16:44:13 -0700 (PDT)
Message-ID: <20160715.164413.2171292428501556413.davem@davemloft.net>
References: <1468577112-7884-1-git-send-email-tremyfr@gmail.com>
	<1468577112-7884-2-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, f.fainelli@gmail.com, manuel.lauss@gmail.com,
	mugunthanvnm@ti.com, ivecera@redhat.com, xypron.glpk@gmx.de,
	netdev@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56590 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751880AbcGOXoO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 19:44:14 -0400
In-Reply-To: <1468577112-7884-2-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philippe Reynes <tremyfr@gmail.com>
Date: Fri, 15 Jul 2016 12:05:12 +0200

> There are two generics functions phy_ethtool_{get|set}_link_ksettings,
> so we can use them instead of defining the same code in the driver.
> 
> There was a check on CAP_NET_ADMIN in au1000_set_settings, but this
> check is already done in dev_ethtool, so no need to repeat it before
> calling the generic function.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
