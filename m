From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][v2] net: phy: fix a bug in get_phy_c45_ids
Date: Mon, 02 Nov 2015 23:02:03 -0500 (EST)
Message-ID: <20151102.230203.435663540046979084.davem@davemloft.net>
References: <1446461313-37628-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
	Shaohui.Xie@freescale.com
To: shh.xie@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39281 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751593AbbKCECF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 23:02:05 -0500
In-Reply-To: <1446461313-37628-1-git-send-email-shh.xie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <shh.xie@gmail.com>
Date: Mon, 2 Nov 2015 18:48:33 +0800

> @@ -205,6 +205,37 @@ struct phy_device *phy_device_create(struct mii_bus *bus, int addr, int phy_id,
>  }
>  EXPORT_SYMBOL(phy_device_create);
>  
> + /* get_phy_c45_devs_in_pkg - reads a MMD's devices in package registers.
> + * @bus: the target MII bus

Please remove the leading space on the first line of this new comment.
