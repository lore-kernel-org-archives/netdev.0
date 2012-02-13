From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sfc: mtd: Use MTD_FAIL_ADDR_UNKNOWN instead of
 0xffffffff
Date: Mon, 13 Feb 2012 00:51:31 -0500 (EST)
Message-ID: <20120213.005131.707348228946745194.davem@davemloft.net>
References: <20120212111308.0267f200@pixies.home.jungo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, linux-net-drivers@solarflare.com,
	linux-mtd@lists.infradead.org, netdev@vger.kernel.org,
	dedekind1@gmail.com
To: shmulik.ladkani@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59254 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751796Ab2BMFxp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2012 00:53:45 -0500
In-Reply-To: <20120212111308.0267f200@pixies.home.jungo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Date: Sun, 12 Feb 2012 11:13:08 +0200

> From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
> 
> As of bb0eb217, MTD_FAIL_ADDR_UNKNOWN should be used to indicate mtd
> erase failure not specific to any particular block.
> 
> Use MTD_FAIL_ADDR_UNKNOWN instead of 0xffffffff when setting
> 'erase->fail_addr' in 'efx_mtd_erase()'.
> 
> Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>

Ben, what would you like me to do with this one?
