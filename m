From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] Gigabit Ethernet driver of Topcliff PCH
Date: Thu, 26 Aug 2010 08:42:19 -0700
Message-ID: <20100826084219.322f43f9@nehalam>
References: <4C763A67.5040107@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	ML netdev <netdev@vger.kernel.org>,
	Greg Rose <gregory.v.rose@intel.com>,
	Maxime Bizon <mbizon@freebox.fr>,
	Kristoffer Glembo <kristoffer@gaisler.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	John Linn <john.linn@xilinx.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	"David S. Miller" <davem@davemloft.net>,
	MeeGo <meego-dev@meego.com>, "Wang, Qi" <qi.wang@intel.com>,
	"Wang, Yong Y" <yong.y.wang@intel.com>,
	Andrew <andrew.chih.howe.khor@intel.com>,
	Intel OTC <joel.clark@intel.com>,
	"Foster, Margie" <margie.foster@intel.com>,
	Toshiharu Okada <okada533@dsn.okisemi.com>,
	Tomoya Morinaga <morinaga526@dsn.okisemi.com>,
	Takahiro Shimizu <shimizu394@dsn.okisemi.com>
To: Masayuki Ohtake <masa-korg@dsn.okisemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:46169 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752309Ab0HZPmW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Aug 2010 11:42:22 -0400
In-Reply-To: <4C763A67.5040107@dsn.okisemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 26 Aug 2010 18:56:55 +0900
Masayuki Ohtake <masa-korg@dsn.okisemi.com> wrote:

> +
> +static struct ethtool_ops pch_gbe_ethtool_ops = {
> +	.get_settings = pch_gbe_get_settings,
> +	.set_settings = pch_gbe_set_settings,
> +	.get_drvinfo = pch_gbe_get_drvinfo,
> +	.get_regs_len = pch_gbe_get_regs_len,
> +	.get_regs = pch_gbe_get_regs,
> +	.get_wol = pch_gbe_get_wol,
> +	.set_wol = pch_gbe_set_wol,
> +	.nway_reset = pch_gbe_nway_reset,
> +	.get_link = ethtool_op_get_link,
> +	.get_ringparam = pch_gbe_get_ringparam,
> +	.set_ringparam = pch_gbe_set_ringparam,
> +	.get_pauseparam = pch_gbe_get_pauseparam,
> +	.set_pauseparam = pch_gbe_set_pauseparam,
> +	.get_rx_csum = pch_gbe_get_rx_csum,
> +	.set_rx_csum = pch_gbe_set_rx_csum,
> +	.get_tx_csum = pch_gbe_get_tx_csum,
> +	.set_tx_csum = pch_gbe_set_tx_csum,
> +	.get_strings = pch_gbe_get_strings,
> +	.get_ethtool_stats = pch_gbe_get_ethtool_stats,
> +	.get_sset_count = pch_gbe_get_sset_count,
> +};
> +

Should be const

-- 
