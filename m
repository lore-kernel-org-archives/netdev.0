From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atl1: Protect atl1_suspend with CONFIG_PM_SLEEP
Date: Tue, 16 Apr 2013 17:47:27 -0400 (EDT)
Message-ID: <20130416.174727.1740704241508622375.davem@davemloft.net>
References: <1366148100-5617-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joe@perches.com,
	fabio.estevam@freescale.com
To: festevam@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51148 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965387Ab3DPVr3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 17:47:29 -0400
In-Reply-To: <1366148100-5617-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <festevam@gmail.com>
Date: Tue, 16 Apr 2013 18:35:00 -0300

> From: Fabio Estevam <fabio.estevam@freescale.com>
> 
> commit 7b7a2bbb690 (atl1: Remove unneeded PM_OPS definitions) removed the 
> definition of atl1_suspend for the !CONFIG_PM_SLEEP case.
> 
> So only call atl1_suspend() when CONFIG_PM_SLEEP is defined and fix the 
> following build error from randconfig:
> 
> drivers/net/ethernet/atheros/atlx/atl1.c: In function 'atl1_shutdown':
> drivers/net/ethernet/atheros/atlx/atl1.c:2888:2: error: implicit declaration of function 'atl1_suspend' [-Werror=implicit-function-declaration]
> 
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>

Applied, thanks.
