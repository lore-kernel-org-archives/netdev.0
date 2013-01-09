From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: fec: Remove 'inline' declarations
Date: Tue, 08 Jan 2013 17:54:28 -0800 (PST)
Message-ID: <20130108.175428.1998635740764887597.davem@davemloft.net>
References: <1357616576-25307-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shawn.guo@linaro.org, netdev@vger.kernel.org, joe@perches.com,
	fabio.estevam@freescale.com
To: festevam@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36031 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756061Ab3AIBy3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2013 20:54:29 -0500
In-Reply-To: <1357616576-25307-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <festevam@gmail.com>
Date: Tue,  8 Jan 2013 01:42:56 -0200

> From: Fabio Estevam <fabio.estevam@freescale.com>
> 
> Fix the following warning when building with W=1 option:
> 
> drivers/net/ethernet/freescale/fec.c:810:1: warning: '__inline__' is not at beginning of declaration [-Wold-style-declaration]
> 
> The inline declaration is pointless in this function, so just remove it.
> 
> While at it, also remove the other 'inline' declarations.
> 
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>

Applied to net-next.
