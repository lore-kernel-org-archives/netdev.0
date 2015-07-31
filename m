From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] stmmac: fix missing MODULE_LICENSE in
 stmmac_platform
Date: Fri, 31 Jul 2015 15:43:44 -0700 (PDT)
Message-ID: <20150731.154344.288497588136948900.davem@davemloft.net>
References: <CAFMg4WCm6rs6xMKPiKGmALc45+ne-xUzQgYHH7zOPotQ-iEqjg@mail.gmail.com>
	<1438362152-11865-1-git-send-email-manabian@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, i.gnatenko.brain@gmail.co,
	netdev@vger.kernel.org, maxime.ripard@anandra.org
To: manabian@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51652 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751070AbbGaWnp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 18:43:45 -0400
In-Reply-To: <1438362152-11865-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joachim Eastwood <manabian@gmail.com>
Date: Fri, 31 Jul 2015 19:02:32 +0200

> Commit 50649ab14982 ("stmmac: drop driver from stmmac platform code")
> was a bit overzealous in removing code and dropped the MODULE_*
> macro's that are still needed since stmmac_platform can be a module.
> Fix this by putting the macro's remvoed in 50649ab14982 back.
> 
> This fixes the following errors when used as a module:
>   stmmac_platform: module license 'unspecified' taints kernel.
>   Disabling lock debugging due to kernel taint
>   stmmac_platform: Unknown symbol devm_kmalloc (err 0)
>   stmmac_platform: Unknown symbol stmmac_suspend (err 0)
>   stmmac_platform: Unknown symbol platform_get_irq_byname (err 0)
>   stmmac_platform: Unknown symbol stmmac_dvr_remove (err 0)
>   stmmac_platform: Unknown symbol platform_get_resource (err 0)
>   stmmac_platform: Unknown symbol of_get_phy_mode (err 0)
>   stmmac_platform: Unknown symbol of_property_read_u32_array (err 0)
>   stmmac_platform: Unknown symbol of_alias_get_id (err 0)
>   stmmac_platform: Unknown symbol stmmac_resume (err 0)
>   stmmac_platform: Unknown symbol stmmac_dvr_probe (err 0)
> 
> Fixes: 50649ab14982 ("stmmac: drop driver from stmmac platform code")
> Reported-by: Igor Gnatenko <i.gnatenko.brain@gmail.com>
> Signed-off-by: Joachim Eastwood <manabian@gmail.com>

Applied, thanks.
