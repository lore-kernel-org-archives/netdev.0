From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: davinci_emac: fix oops caused by uninitialized
 ndev->dev
Date: Thu, 22 May 2014 15:22:56 -0400 (EDT)
Message-ID: <20140522.152256.863726183754410883.davem@davemloft.net>
References: <1400580697-24994-1-git-send-email-nsekhar@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: khilman@linaro.org, davinci-linux-open-source@linux.davincidsp.com,
	netdev@vger.kernel.org, prabhakar.csengg@gmail.com,
	mugunthanvnm@ti.com
To: nsekhar@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41693 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750760AbaEVTW6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2014 15:22:58 -0400
In-Reply-To: <1400580697-24994-1-git-send-email-nsekhar@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sekhar Nori <nsekhar@ti.com>
Date: Tue, 20 May 2014 15:41:37 +0530

> Commit e194312854edc22a2faf1931b3c0608fe20cb969 (drivers: net:
> davinci_cpdma: Convert kzalloc() to devm_kzalloc()) triggered
> a bug in emac_probe() wherein dev member of net_device is used
> for devres allocations even before it is initialized.
> 
> This patch fixes that by using the struct device in platform_device
> instead.
> 
> While at it, use &pdev->dev consistently for console messages instead
> of using ndev->dev for just one case and remove an unnecessary line
> continuation.
> 
> Reported-by: Kevin Hilman <khilman@linaro.org>
> Helped-by: George Cherian <george.cherian@ti.com>
> Signed-off-by: Sekhar Nori <nsekhar@ti.com>
> ---
> This patch fixes a bug in linux-next so it can wait for
> v3.16

Applied to net-next, thanks.
