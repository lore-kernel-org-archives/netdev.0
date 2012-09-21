From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3 V2] phy/micrel: Implement support for KSZ8021
Date: Fri, 21 Sep 2012 13:42:15 -0400 (EDT)
Message-ID: <20120921.134215.1719885507288305623.davem@davemloft.net>
References: <1348195976-31703-1-git-send-email-marex@denx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, david.choi@micrel.com,
	nobuhiro.iwamatsu.yj@renesas.com, fabio.estevam@freescale.com,
	shawn.guo@linaro.org
To: marex@denx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50827 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932070Ab2IURmR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2012 13:42:17 -0400
In-Reply-To: <1348195976-31703-1-git-send-email-marex@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Vasut <marex@denx.de>
Date: Fri, 21 Sep 2012 04:52:54 +0200

> +	phy_write(phydev, MII_KSZPHY_OMSO,
> +		KSZPHY_OMSO_B_CAST_OFF | KSZPHY_OMSO_RMII_OVERRIDE);

This is not indented properly.  The goal is not to exclusively use
TAB characters to indent code until it sort-of looks fine.

Rather, the goal is to properly line up function arguments with
the first column after the openning parenthesis on the previous
line.  Using TAB and SPACE characters, as needed.

> +	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause
> +				| SUPPORTED_Asym_Pause),

This is similarly not styled properly.

Besies being indented imporperly on the second line, the final "|"
character should be at the end of the first line, rather than
start the second line.

Resubmit this entire patch series, not just this one patch, once
you've made these corrections.

Thanks.
