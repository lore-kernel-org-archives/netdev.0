From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: mvmdio: add select PHYLIB
Date: Sat, 13 Apr 2013 16:48:34 -0400 (EDT)
Message-ID: <20130413.164834.1146247422887398317.davem@davemloft.net>
References: <1365869936-17190-1-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch, jason@lakedaemon.net,
	maen@marvell.com, alior@marvell.com,
	gregory.clement@free-electrons.com,
	ezequiel.garcia@free-electrons.com, florian@openwrt.org
To: thomas.petazzoni@free-electrons.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36404 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753362Ab3DMUsi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Apr 2013 16:48:38 -0400
In-Reply-To: <1365869936-17190-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Date: Sat, 13 Apr 2013 18:18:56 +0200

> The mvmdio driver uses the phylib API, so it should select the PHYLIB
> symbol, otherwise, a build with mvmdio (but without mvneta) fails to
> build with undefined symbols such as mdiobus_unregister, mdiobus_free,
> etc.
> 
> The mvneta driver does not use the phylib API directly, so it does not
> need to select PHYLIB. It already selects the mvmdio driver anyway.
> 
> Historically, this problem is due to the fact that the PHY handling
> was originally part of mvneta, and was later moved to a separate
> driver, without updating the Kconfig select statements
> accordingly. And since there was no functional reason to use mvmdio
> without mvneta, this case was not tested.
> 
> Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>

Applied and queued up for -stable, thanks.
