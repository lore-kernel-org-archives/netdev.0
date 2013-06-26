From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1 2/3] pch_gbe: convert pr_* to netdev_*
Date: Wed, 26 Jun 2013 13:41:08 -0700 (PDT)
Message-ID: <20130626.134108.1845027788447841042.davem@davemloft.net>
References: <1372263217-1938-1-git-send-email-andriy.shevchenko@linux.intel.com>
	<1372263217-1938-3-git-send-email-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dvhart@linux.intel.com
To: andriy.shevchenko@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47198 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751444Ab3FZUlJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jun 2013 16:41:09 -0400
In-Reply-To: <1372263217-1938-3-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Date: Wed, 26 Jun 2013 19:13:36 +0300

> diff --git a/drivers/staging/media/lirc/lirc_igorplugusb.c b/drivers/staging/media/lirc/lirc_igorplugusb.c
> index 28c8b0b..25df7cf 100644
> --- a/drivers/staging/media/lirc/lirc_igorplugusb.c
> +++ b/drivers/staging/media/lirc/lirc_igorplugusb.c
> @@ -408,7 +408,7 @@ static int igorplugusb_remote_probe(struct usb_interface *intf,
>  	dprintk(DRIVER_NAME "[%d]: bytes_in_key=%zu maxp=%d\n",
>  		devnum, CODE_LENGTH, maxp);
>  
> -	ir = devm_kzalloc(&intf->dev, sizeof(*ir), GFP_KERNEL);
> +	ir = devm_kzalloc(&dev->dev, sizeof(*ir), GFP_KERNEL);
>  	if (!ir)
>  		return -ENOMEM;
>  

This definitely wasn't supposed to be in this patch series.

Please repost this set with this hunk removed.
