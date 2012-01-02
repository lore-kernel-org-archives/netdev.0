From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r6040: use an unique MDIO bus name
Date: Mon, 02 Jan 2012 15:49:30 -0500 (EST)
Message-ID: <20120102.154930.1761330488764990513.davem@davemloft.net>
References: <1325497800-21450-1-git-send-email-florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vova.kolpakov@gmail.com
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33850 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751454Ab2ABUti (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2012 15:49:38 -0500
In-Reply-To: <1325497800-21450-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian@openwrt.org>
Date: Mon,  2 Jan 2012 10:50:00 +0100

> +	snprintf(lp->mii_bus->id, MII_BUS_ID_SIZE, "%s-%x",
> +					dev_name(&pdev->dev), card_idx);

Please don't be so sloppy with the formatting like this,
make the arguments on the second line get indented exactly
to the first column after the openning parenthesis on the
first line.

If you can't be bothered to get this right by hand, use
something like emacs's C-mode to do it for you when you hit
TAB.
