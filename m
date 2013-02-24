From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] gianfar: fix compile fail for NET_POLL=y due to
 struct packing
Date: Sun, 24 Feb 2013 12:04:58 -0500 (EST)
Message-ID: <20130224.120458.1711395595508489332.davem@davemloft.net>
References: <1361717023.16950.12.camel@pasglop>
	<1361720311-13267-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	benh@kernel.crashing.org, claudiu.manoil@freescale.com,
	jianhua.xie@freescale.com
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39491 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753286Ab3BXRFD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Feb 2013 12:05:03 -0500
In-Reply-To: <1361720311-13267-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Sun, 24 Feb 2013 10:38:31 -0500

> Commit ee873fda3bec7c668407b837fc5519eb961fcd37 ("gianfar: Pack struct
> gfar_priv_grp into three cachelines") moved the irq number and names
> off into a separate struct and created accessors for them.  However
> it was never tested with NET_POLL enabled, and so some conversions
> that were simply overlooked went undetected until now.
> 
> Make the netpoll ones also use the gfar_irq() accessors.
> 
> Reported-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Cc: Claudiu Manoil <claudiu.manoil@freescale.com>
> Cc: Jianhua Xie <jianhua.xie@freescale.com>
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

Applied, thanks.
