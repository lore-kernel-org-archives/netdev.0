From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/2] net: phy: Prevent an MDIO bus from being
 unloaded while in use
Date: Thu, 24 Jul 2014 18:10:44 -0700 (PDT)
Message-ID: <20140724.181044.1195125881203135720.davem@davemloft.net>
References: <1406144852-7379-1-git-send-email-ezequiel.garcia@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
	thomas.petazzoni@free-electrons.com,
	gregory.clement@free-electrons.com
To: ezequiel.garcia@free-electrons.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56425 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750795AbaGYBKq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2014 21:10:46 -0400
In-Reply-To: <1406144852-7379-1-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Date: Wed, 23 Jul 2014 16:47:30 -0300

> Changes from v1:
>   * Dropped the unneeded module_put() on phy_attach_direct().
> 
> The motivation of this small series is to fix the current lack of relationship
> between an ethernet driver and the MDIO bus behind the PHY device. In such
> cases, we would find no visible link between the drivers:
 ...
> Which means nothing prevents the MDIO driver from being removed:
 ...
> This patchset fixes this problem by adding a pair of module_{get,put},
> so the module reference count is increased when the PHY device is attached
> and is decreased when the PHY is detached.
> 
> Tested with mvneta and mv643xx_eth drivers, which depend on the mvmdio
> driver to handle MDIO. This series applies on both net and net-next branches.

Series applied, thank you.
