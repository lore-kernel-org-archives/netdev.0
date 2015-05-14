From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] net: phy: broken turn-around support
Date: Thu, 14 May 2015 13:41:18 -0400 (EDT)
Message-ID: <20150514.134118.660863138802455644.davem@davemloft.net>
References: <1431442563-10218-1-git-send-email-bert@biot.com>
	<1431452006-3219-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jogo@openwrt.org, bert@biot.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40502 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161085AbbENRlT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 13:41:19 -0400
In-Reply-To: <1431452006-3219-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Tue, 12 May 2015 10:33:23 -0700

> This is an attempt at solving the broken turn-around problem in a way that
> is not specific to the mdio-gpio driver, since it affects different kinds of
> platforms.
> 
> We cannot make that localized to PHY device drivers because probing the PHY
> device which has a broken turn-around can fail as early as in get_phy_id(),
> therefore we need a bit of help from Device Tree/platform_data.

Series applied, thanks Florian.
