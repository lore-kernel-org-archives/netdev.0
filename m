From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next 5/8] net: dsa: add new API to register
 switch devices
Date: Sun, 03 May 2015 22:09:20 -0400 (EDT)
Message-ID: <20150503.220920.1744802036606063470.davem@davemloft.net>
References: <1430359064-23454-1-git-send-email-f.fainelli@gmail.com>
	<1430359064-23454-6-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, linux@roeck-us.net,
	andrew@lunn.ch, cphealy@gmail.com, mathieu@codeaurora.org,
	jonasj76@gmail.com, andrey.volkov@nexvision.fr,
	Chris.Packham@alliedtelesis.co.nz
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58522 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750977AbbEDCJX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 May 2015 22:09:23 -0400
In-Reply-To: <1430359064-23454-6-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Wed, 29 Apr 2015 18:57:41 -0700

> @@ -897,7 +1022,6 @@ static int dsa_resume(struct device *d)
>  static SIMPLE_DEV_PM_OPS(dsa_pm_ops, dsa_suspend, dsa_resume);
>  
>  static const struct of_device_id dsa_of_match_table[] = {
> -	{ .compatible = "brcm,bcm7445-switch-v4.0" },
>  	{ .compatible = "marvell,dsa", },
>  	{}
>  };

Hmmm, is this really meant to be a part of this patch?

If it is, you'll need to explain this clearly in the commit message
so others can understand too.
