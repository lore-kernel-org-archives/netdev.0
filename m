From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/4] net: systemport: add Broadcom SYSTEMPORT
 Ethernet MAC driver
Date: Mon, 21 Apr 2014 13:46:44 -0400 (EDT)
Message-ID: <20140421.134644.1829764866020217667.davem@davemloft.net>
References: <1398101494-27959-1-git-send-email-f.fainelli@gmail.com>
	<1398101494-27959-2-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60624 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753208AbaDURqq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2014 13:46:46 -0400
In-Reply-To: <1398101494-27959-2-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Mon, 21 Apr 2014 10:31:31 -0700

> +#ifdef CONFIG_PHYS_ADDR_T_64BIT
> +	__raw_writel(upper_32_bits(addr) & DESC_ADDR_HI_MASK,
> +				d + DESC_ADDR_HI_STATUS_LEN);
> +#endif

When a function call spans multiple lines, the arguments on the second
and subsequent lines need to start exactly at the first column after
the openning parenthesis.

Please audit and fix this in your entire submission.

> +static int bcm_sysport_set_settings(struct net_device *dev,
> +				    struct ethtool_cmd *cmd)

Likewise for functions declarations and definitions.

Also, no NAPI support?  The locking and SKB freeing looks quite baroque
as a consequence of this.
