From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH] net: davinci_emac: fix oops caused by uninitialized ndev->dev
Date: Tue, 20 May 2014 15:44:51 +0530
Message-ID: <537B2B1B.2000501@ti.com>
References: <1400580697-24994-1-git-send-email-nsekhar@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Kevin Hilman <khilman@linaro.org>,
	Linux DaVinci Mailing List
	<davinci-linux-open-source@linux.davincidsp.com>,
	Linux netdev Mailing List <netdev@vger.kernel.org>,
	Prabhakar Lad <prabhakar.csengg@gmail.com>
To: Sekhar Nori <nsekhar@ti.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:38459 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752645AbaETKO5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2014 06:14:57 -0400
In-Reply-To: <1400580697-24994-1-git-send-email-nsekhar@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 20 May 2014 03:41 PM, Sekhar Nori wrote:
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

Acked-by: Mugunthan V N <mugunthanvnm@ti.com>

Regards
Mugunthan V N
