From: David Miller <davem@davemloft.net>
Subject: Re: [v7, 2/6] fsl/fman: Add FMan support
Date: Mon, 02 Nov 2015 23:17:50 -0500 (EST)
Message-ID: <20151102.231750.1882562463767220834.davem@davemloft.net>
References: <1446467416-15992-1-git-send-email-igal.liberman@freescale.com>
	<1446467416-15992-3-git-send-email-igal.liberman@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-kernel@vger.kernel.org, scottwood@freescale.com,
	madalin.bucur@freescale.com, pebolle@tiscali.nl,
	joakim.tjernlund@transmode.se, ppc@mindchasers.com,
	stephen@networkplumber.org
To: igal.liberman@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39378 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750716AbbKCERx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 23:17:53 -0500
In-Reply-To: <1446467416-15992-3-git-send-email-igal.liberman@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <igal.liberman@freescale.com>
Date: Mon, 2 Nov 2015 14:30:12 +0200

> +static int clear_iram(struct fman *fman)
> +{
> +	struct fman_iram_regs __iomem *iram;
> +	int i, count;
> +
> +	iram = (struct fman_iram_regs __iomem *)(fman->base_addr + IMEM_OFFSET);

"fman->base_addr" is of type "void __iomem *", therefore no cast should
be necessary at all.

Please audit your entire driver submission for this problem.

THanks.
