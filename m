From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v2] ethernet driver for the WIZnet W5300 chip
Date: Tue, 20 Mar 2012 18:08:01 +0000
Message-ID: <1332266881.2489.4.camel@bwh-desktop.uk.solarflarecom.com>
References: <1332149037-12025-1-git-send-email-msink@permonline.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Mike Sinkovsky <msink@permonline.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1332149037-12025-1-git-send-email-msink@permonline.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-03-19 at 14:23 +0500, Mike Sinkovsky wrote:
> Based on original driver from chip manufacturer, but with many cleanups.
> Hope now it is near to mainline kernel quality.
> 
> Tested and used in production with Blackfin BF531 embedded processor.
[...]
> +static void w5300_get_drvinfo(struct net_device *ndev,
> +			      struct ethtool_drvinfo *info)
> +{
> +	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
> +	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
> +	strlcpy(info->fw_version, "N/A", sizeof(info->fw_version));
[...]

Nitpick: if you don't have firmware, don't set fw_version at all.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
