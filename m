From: Joe Perches <joe@perches.com>
Subject: Re: Subject: [PATCH 3/6] bna: Brocade 10Gb Ethernet device driver
Date: Mon, 23 Nov 2009 20:58:04 -0800
Message-ID: <1259038684.16503.202.camel@Joe-Laptop.home>
References: <200911240351.nAO3p1bG025630@blc-10-10.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, adapter_linux_open_src_team@brocade.com
To: Rasesh Mody <rmody@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1113 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752241AbZKXE56 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Nov 2009 23:57:58 -0500
In-Reply-To: <200911240351.nAO3p1bG025630@blc-10-10.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> +#ifndef dev_err
> +#define dev_err(dev, format, arg...)	\
> +	printk(KERN_ERR "bna: " format, ## arg)
> +#endif
> +#ifndef dev_info
> +#define dev_info(dev, format, arg...)	\
> +	printk(KERN_INFO "bna: " format, ## arg)
> +#endif
> +#ifndef dev_warn
> +#define dev_warn(dev, format, arg...)	\
> +	printk(KERN_WARNING "bna: " format, ## arg)
> +#endif

Don't do this.  Just include device.h

