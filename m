From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v3 2/2] net: ethernet: add driver for Aurora VLSI NB8800
 Ethernet controller
Date: Tue, 27 Oct 2015 15:02:09 +0900
Message-ID: <20151027150209.043946d4@samsung9>
References: <1445895295-16778-1-git-send-email-mans@mansr.com>
	<1445895295-16778-2-git-send-email-mans@mansr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	slash.tmp@free.fr
To: Mans Rullgard <mans@mansr.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445895295-16778-2-git-send-email-mans@mansr.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> +
> +static struct ethtool_ops nb8800_ethtool_ops = {
Ops should be const

> +	.get_settings		= nb8800_get_settings,
> +	.set_settings		= nb8800_set_settings,
> +	.nway_reset		= nb8800_nway_reset,
> +	.get_link		= ethtool_op_get_link,
> +};
> +

Since you are implementing ethtool please add a driver
info function.
