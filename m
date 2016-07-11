From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] net: dsa: b53: Add Broadcom NSP switch
 support
Date: Mon, 11 Jul 2016 12:52:24 -0700 (PDT)
Message-ID: <20160711.125224.1177445395852680299.davem@davemloft.net>
References: <1468003153-14026-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jon.mason@broadcom.com, andrew@lunn.ch,
	zajec5@gmail.com, vivien.didelot@savoirfairelinux.com,
	bcm-kernel-feedback-list@broadcom.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59776 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752341AbcGKTwj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2016 15:52:39 -0400
In-Reply-To: <1468003153-14026-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Fri,  8 Jul 2016 11:39:11 -0700

> This patch series updates the B53 driver to support Broadcom's Northstar Plus
> Soc integrated switch.
> 
> Unlike the version of the core present in BCM5301x/Northstar, we cannot read the
> full chip id of the switch, so we need to get the information about our switch
> id from Device Tree.
> 
> Other than that, this is a regular Broadcom Ethernet switch which is register
> compatible for all practical purposes with the existing switch driver.
> 
> Since DSA requires a working CPU Ethernet MAC driver this depends on Jon
> Mason's AMAC/BGMAC driver changes to support NSP. Board specific changes depend
> on patches present in Broadcom's ARM SoC branches and will be posted in a short
> while.

Series applied, thanks.
