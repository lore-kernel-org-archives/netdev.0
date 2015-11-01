From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fec: Use gpio_set_value_cansleep()
Date: Sun, 01 Nov 2015 12:03:22 -0500 (EST)
Message-ID: <20151101.120322.53539521147999460.davem@davemloft.net>
References: <1446034830-13640-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fabio.estevam@freescale.com
To: festevam@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53880 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751123AbbKARDY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Nov 2015 12:03:24 -0500
In-Reply-To: <1446034830-13640-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <festevam@gmail.com>
Date: Wed, 28 Oct 2015 10:20:30 -0200

> From: Fabio Estevam <fabio.estevam@freescale.com>
> 
> We are in a context where we can sleep, and the FEC PHY reset gpio
> may be on an I2C expander. Use the cansleep() variant when
> setting the GPIO value.
> 
> Based on a patch from Russell King for pci-mvebu.c.
> 
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>

Applied.
