From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [net-next:master 294/295] drivers/net/ethernet/stmicro/stmmac/stmmac_main.c:287:3:
 error: implicit declaration of function 'phy_init_eee'
Date: Fri, 06 Jul 2012 10:08:58 +0200
Message-ID: <4FF69D1A.2030903@st.com>
References: <20120701113521.GA11294@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: wfg@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog117.obsmtp.com ([207.126.144.143]:43677 "EHLO
	eu1sys200aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751867Ab2GFIJU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2012 04:09:20 -0400
In-Reply-To: <20120701113521.GA11294@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/1/2012 1:35 PM, wfg@linux.intel.com wrote:
> Hi Giuseppe,
> 
> Here is a build dependency: the below commit used some functions
> provided by the immediate next commit "phy: add the EEE support and
> the way to access to the MMD registers."
> 

I had built all w/o issues (on arm/sh/x86) but I'm looking at the build
again.
I hope to fix it in case of I am able to reproduce the problem because
I'm on business trip and I have some issue to run tests :-(

I'll try

Peppe

> ---
> Kernel build failed on
> 
> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
> head:   a59a4d1921664da63d801ba477950114c71c88c9
> commit: d765955d2ae0b88781a0db3a5bacfe4241925e09 [294/295] stmmac: add the Energy Efficient Ethernet support
> config: x86_64-allmodconfig
> 
> All related error/warning messages:
> 
> drivers/net/ethernet/stmicro/stmmac/stmmac_main.c: In function 'stmmac_eee_init':
> drivers/net/ethernet/stmicro/stmmac/stmmac_main.c:287:3: error: implicit declaration of function 'phy_init_eee' [-Werror=implicit-function-declaration]
> drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c: In function 'stmmac_get_ethtool_stats':
> drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c:380:4: error: implicit declaration of function 'phy_get_eee_err' [-Werror=implicit-function-declaration]
> drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c: In function 'stmmac_ethtool_op_get_eee':
> drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c:494:2: error: implicit declaration of function 'phy_ethtool_get_eee' [-Werror=implicit-function-declaration]
> drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c: In function 'stmmac_ethtool_op_set_eee':
> drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c:519:2: error: implicit declaration of function 'phy_ethtool_set_eee' [-Werror=implicit-function-declaration]
> 
> drivers/net/ethernet/stmicro/stmmac/stmmac_main.c:287:
>    284		/* MAC core supports the EEE feature. */
>    285		if (priv->dma_cap.eee) {
>    286			/* Check if the PHY supports EEE */
>  > 287			if (phy_init_eee(priv->phydev, 1))
>    288				goto out;
>    289	
>    290			priv->eee_active = 1;
> 
> ---
> 0-DAY kernel build testing backend         Open Source Technology Centre
> Fengguang Wu <wfg@linux.intel.com>                     Intel Corporation
> 
