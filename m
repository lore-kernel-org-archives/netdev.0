From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] net: phy: bcm7xxx initial read/write workaround
Date: Sun, 28 Jun 2015 20:29:41 -0700 (PDT)
Message-ID: <20150628.202941.1570325669605547802.davem@davemloft.net>
References: <1435340346-10297-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pgynther@google.com, jaedon.shin@gmail.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40005 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753115AbbF2D3m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jun 2015 23:29:42 -0400
In-Reply-To: <1435340346-10297-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Fri, 26 Jun 2015 10:39:03 -0700

> This patch series fixes occasional BCM7xxx PHY driver binding failure due
> to a harware bug where the first read or write does not come out of the PHY
> MDIO management controller.
> 
> Since we have two different MDIO controllers using this PHY, a similar
> need to be replicated in GENET and UniMAC MDIO.

Series applied, thanks Florian.
