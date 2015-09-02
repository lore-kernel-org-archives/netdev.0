From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bgmac: Update fixed_phy_register()
Date: Wed, 02 Sep 2015 11:40:32 -0700 (PDT)
Message-ID: <20150902.114032.437252357251505136.davem@davemloft.net>
References: <1441211159-31328-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nbd@openwrt.org, andrew@lunn.ch, broonie@kernel.org,
	netdev@vger.kernel.org, fabio.estevam@freescale.com
To: festevam@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38434 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932076AbbIBSke (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 14:40:34 -0400
In-Reply-To: <1441211159-31328-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <festevam@gmail.com>
Date: Wed,  2 Sep 2015 13:25:59 -0300

> From: Fabio Estevam <fabio.estevam@freescale.com>
> 
> Commit a5597008dbc2 ("phy: fixed_phy: Add gpio to determine link up/down.")
> added a new argument to fixed_phy_register(), but missed to update bgmac
> driver, causing the following build failure:
> 
> drivers/net/ethernet/broadcom/bgmac.c:1450:2: error: too few arguments to function 'fixed_phy_register'
> 
> Add the missing argument.
> 
> Reported-by: Mark Brown <broonie@kernel.org>
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>

Applied, thanks.
