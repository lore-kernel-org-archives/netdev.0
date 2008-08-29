From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 6/7] [RFC] qlge: New Driver: Add ethtool source file
 qlge_ethtool.c
Date: Fri, 29 Aug 2008 14:20:23 -0700
Message-ID: <20080829142023.2fab969d@extreme>
References: <20080829210610.GA14654@susedev.qlogic.org>
	<1220044102828-git-send-email-ron.mercer@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: Ron Mercer <ron.mercer@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:46231 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754847AbYH2VUZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Aug 2008 17:20:25 -0400
In-Reply-To: <1220044102828-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> +static struct ethtool_ops qlge_ethtool_ops = {
> +	.get_drvinfo = ql_get_drvinfo,
> +	.get_msglevel = ql_get_msglevel,
> +	.set_msglevel = ql_set_msglevel,
> +	.get_rx_csum = ql_get_rx_csum,
> +	.set_rx_csum = ql_set_rx_csum,
> +	.get_tx_csum = ethtool_op_get_tx_csum,
> +	.get_sg = ethtool_op_get_sg,
> +	.set_sg = ethtool_op_set_sg,
> +	.get_tso = ethtool_op_get_tso,
> +	.set_tso = ql_set_tso,
> +	.get_coalesce = ql_get_coalesce,
> +	.set_coalesce = ql_set_coalesce,
> +	.get_sset_count = ql_get_sset_count,
> +	.get_strings = ql_get_strings,
> +	.get_ethtool_stats = ql_get_ethtool_stats,

	.get_link = ethtool_op_getlink,

Also please provide get_settings since this is used by
bridging to determine speed.
