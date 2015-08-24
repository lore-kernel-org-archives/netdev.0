From: Sekhar Nori <nsekhar@ti.com>
Subject: Re: [net-next PATCH 1/3] drivers: net: cpsw: add am335x errata workarround
 for interrutps
Date: Mon, 24 Aug 2015 15:34:24 +0530
Message-ID: <55DAEC28.3030107@ti.com>
References: <1439373175-8650-1-git-send-email-mugunthanvnm@ti.com> <1439373175-8650-2-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <devicetree@vger.kernel.org>, <linux-omap@vger.kernel.org>,
	"David S . Miller" <davem@davemloft.net>,
	Tony Lindgren <tony@atomide.com>, <alex.aring@gmail.com>
To: Mugunthan V N <mugunthanvnm@ti.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:44219 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932738AbbHXKEc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Aug 2015 06:04:32 -0400
In-Reply-To: <1439373175-8650-2-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Mugunthan,

On Wednesday 12 August 2015 03:22 PM, Mugunthan V N wrote:
> +static const struct of_device_id cpsw_of_mtable[] = {
> +	{ .compatible = "ti,cpsw", .data = &cpsw_devtype[CPSW], },

> +	{ .compatible = "ti,am335x-cpsw", .data = &cpsw_devtype[AM335X_CPSW], },
> +	{ .compatible = "ti,am4372-cpsw", .data = &cpsw_devtype[AM4372_CPSW], },
> +	{ .compatible = "ti,dra7-cpsw", .data = &cpsw_devtype[DRA7_CPSW], },

I do not see documentation added for these compatibles. Since the series
is already applied, can you send additional patches adding documentation?

Thanks,
Sekhar
