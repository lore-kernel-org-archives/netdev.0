From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sh: sh_eth: Add support SH7734
Date: Wed, 21 Mar 2012 16:58:18 -0400 (EDT)
Message-ID: <20120321.165818.1166540551487888245.davem@davemloft.net>
References: <1332314014-31992-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nobuhiro.iwamatsu.yj@renesas.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42635 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750966Ab2CUU60 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2012 16:58:26 -0400
In-Reply-To: <1332314014-31992-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Date: Wed, 21 Mar 2012 16:13:34 +0900

> Add define of SH7734 register and sh_eth_reset_hw_crc function.
> 
> Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>

This patch doesn't apply cleanly at all, also:

> -#elif defined(CONFIG_CPU_SUBTYPE_SH7763)
> +#elif defined(CONFIG_CPU_SUBTYPE_SH7734) ||\
> +		defined(CONFIG_CPU_SUBTYPE_SH7763)

This looks terrible, please don't split this line up like that.

If you have to, at least put a space before the backslash at the end
of the first line and make the "defined" on the second line match up,
column wise, with the "defined" on the previous line.
