From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] drivers/net: add 6WIND SHULTI support
Date: Wed, 27 Apr 2016 12:34:01 -0400 (EDT)
Message-ID: <20160427.123401.2056055787059013850.davem@davemloft.net>
References: <1461749838-4613-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50945 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752906AbcD0QeE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 12:34:04 -0400
In-Reply-To: <1461749838-4613-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Wed, 27 Apr 2016 11:37:18 +0200

> +/* rtnl linkinfo attributes */
> +enum {
> +	IFLA_SHULTI_UNSPEC,
> +	IFLA_SHULTI_SWDEV_ID,
> +	IFLA_SHULTI_SWDEV_PORTID,
> +	IFLA_SHULTI_PHYS_PORT_NAME,
> +
> +	__IFLA_SHULTI_MAX
> +#define IFLA_SHULTI_MAX	(__IFLA_SHULTI_MAX - 1)
> +};
> +
 ...
> +enum {
> +	SHULTI_A_UNSPEC,
> +	SHULTI_A_NL_PORTIDS,
> +	SHULTI_A_SWDEV_PORTID,
> +	SHULTI_A_RX_QUEUES,
> +	SHULTI_A_ERRCODE,
> +	SHULTI_A_IFINDEX,
> +	SHULTI_A_LINK_STATUS,
> +	SHULTI_A_PACKET,
> +	SHULTI_A_STATS,
> +	SHULTI_A_VLAN_VID,
> +	SHULTI_A_DRVINFO,
> +	SHULTI_A_SETTINGS,
> +	SHULTI_A_RX_MODES,
> +	SHULTI_A_UC_ADDR,
> +	SHULTI_A_MC_ADDR,
> +	SHULTI_A_STP_STATE,
> +	SHULTI_A_BR_STATE_LEARNING,
> +	SHULTI_A_BR_AGEING_TIME,
> +	SHULTI_A_BR_FDB,
> +
> +	__SHULTI_A_MAX
> +#define SHULTI_A_MAX	(__SHULTI_A_MAX - 1)
> +};
> +

If our existing netlink facilities for switchdevs are not sufficient to properly
report and configure the state of your device, extend it rather than making custom
netlink stuff.
