From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 08/10] net/macb: macb_get_drvinfo: add GEM/MACB suffix
 to differentiate revision
Date: Wed, 05 Sep 2012 17:31:18 -0400 (EDT)
Message-ID: <20120905.173118.1107211725393320514.davem@davemloft.net>
References: <cover.1346775479.git.nicolas.ferre@atmel.com>
	<fc701a2ed18198b7a671c55f1e65725f1709509c.1346775479.git.nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	havard@skinnemoen.net, plagnioj@jcrosoft.com, jamie@jamieiles.com,
	linux-kernel@vger.kernel.org, patrice.vilchez@atmel.com
To: nicolas.ferre@atmel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <fc701a2ed18198b7a671c55f1e65725f1709509c.1346775479.git.nicolas.ferre@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nicolas Ferre <nicolas.ferre@atmel.com>
Date: Wed, 5 Sep 2012 11:00:53 +0200

>  	strcpy(info->driver, bp->pdev->dev.driver->name);
> +	if (macb_is_gem(bp))
> +		strcat(info->driver, " GEM");
> +	else
> +		strcat(info->driver, " MACB");

This is a driver string, which means the software driver, and has
absolutely nothing to do with the exact type of the underlying
physical hardware.

Therefore the these suffixes should be left out of the driver string.
