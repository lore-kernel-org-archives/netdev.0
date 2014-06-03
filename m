From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fec: Include pinctrl header file
Date: Mon, 02 Jun 2014 18:03:46 -0700 (PDT)
Message-ID: <20140602.180346.41191281280269462.davem@davemloft.net>
References: <1401734670-30141-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: B38611@freescale.com, netdev@vger.kernel.org
To: fabio.estevam@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38274 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751756AbaFCBDs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 21:03:48 -0400
In-Reply-To: <1401734670-30141-1-git-send-email-fabio.estevam@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>
Date: Mon, 2 Jun 2014 15:44:30 -0300

> Commit 5bbde4d2ec ("net: fec: use pinctrl PM helpers") caused the following
> build error on m68k:
> 
> drivers/net/ethernet/freescale/fec_main.c: In function 'fec_enet_open':
> drivers/net/ethernet/freescale/fec_main.c:1819:2: error: implicit declaration of function 'pinctrl_pm_select_default_state' [-Werror=implicit-function-declaration]
> drivers/net/ethernet/freescale/fec_main.c: In function 'fec_enet_close':
> drivers/net/ethernet/freescale/fec_main.c:1863:2: error: implicit declaration of function 'pinctrl_pm_select_sleep_state' [-Werror=implicit-function-declaration]
> 
> In order to fix the build error, include the linux/pinctrl/consumer.h header
> file.
> 
> Reported-by: kbuild test robot <fengguang.wu@intel.com> 
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>

Applied, thank you.
