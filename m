From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: ipv6: ndisc: Fix warning when CONFIG_SYSCTL=n
Date: Mon, 18 Nov 2013 14:49:52 -0500 (EST)
Message-ID: <20131118.144952.1387398381461593052.davem@davemloft.net>
References: <1384570328-21666-1-git-send-email-festevam@gmail.com>
	<1384570328-21666-2-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fabio.estevam@freescale.com
To: festevam@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49411 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751563Ab3KRTt4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 14:49:56 -0500
In-Reply-To: <1384570328-21666-2-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <festevam@gmail.com>
Date: Sat, 16 Nov 2013 00:52:08 -0200

> From: Fabio Estevam <fabio.estevam@freescale.com>
> 
> When CONFIG_SYSCTL=n the following build warning happens:
> 
> net/ipv6/ndisc.c:1730:1: warning: label 'out' defined but not used [-Wunused-label]
> 
> The 'out' label is only used when CONFIG_SYSCTL=y, so move it inside the 
> 'ifdef CONFIG_SYSCTL' block.
> 
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>

Applied.
