From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/7 v2] net: bcmgenet: integrated GPHY power
 up/down
Date: Mon, 23 Mar 2015 22:11:11 -0400 (EDT)
Message-ID: <20150323.221111.1998242023354027480.davem@davemloft.net>
References: <1427148597-28337-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jaedon.shin@gmail.com, pgynther@google.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59972 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752395AbbCXCLN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 22:11:13 -0400
In-Reply-To: <1427148597-28337-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Mon, 23 Mar 2015 15:09:50 -0700

> This patch series implements integrated Gigabit PHY power up/down, which allows
> us to save close to 300mW on some designs when the Gigabit PHY is known to be
> unused (e.g: during bcmgenet_close or bcmgenet_suspend not doing Wake-on-LAN).
> 
> Changes in v2:
> 
> - drop an extra bcmgenet_ext_readl in bcmgenet_phy_power_set

This looks fine, series applied.
