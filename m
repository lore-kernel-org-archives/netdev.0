From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v5 2/8] dpaa_eth: add support for DPAA Ethernet
Date: Fri, 04 Dec 2015 14:55:49 -0500 (EST)
Message-ID: <20151204.145549.859527220803940077.davem@davemloft.net>
References: <1449150589-26253-1-git-send-email-madalin.bucur@freescale.com>
	<1449150589-26253-3-git-send-email-madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-kernel@vger.kernel.org, scottwood@freescale.com,
	igal.liberman@freescale.com, ppc@mindchasers.com, joe@perches.com,
	pebolle@tiscali.nl, joakim.tjernlund@transmode.se,
	gregkh@linuxfoundation.org
To: madalin.bucur@freescale.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449150589-26253-3-git-send-email-madalin.bucur@freescale.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Madalin Bucur <madalin.bucur@freescale.com>
Date: Thu, 3 Dec 2015 15:49:43 +0200

> @@ -0,0 +1,22 @@
> +menuconfig FSL_DPAA_ETH
> +	tristate "DPAA Ethernet"
> +	depends on FSL_SOC && FSL_BMAN && FSL_QMAN && FSL_FMAN
> +	select PHYLIB
> +	select FSL_FMAN_MAC

I do not see the FSL_FMAN_MAC Kconfig symbol defined anywhere in the
tree.
