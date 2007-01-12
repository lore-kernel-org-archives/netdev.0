From: Amit Kale <amitkale@netxen.com>
Subject: Re: [PATCH] netxen_nic_main.c: Convert pci_module_init() to pci_register_driver()
Date: Fri, 12 Jan 2007 19:59:27 +0530
Message-ID: <200701121959.27490.amitkale@netxen.com>
References: <45A78ACA.1010600@student.ltu.se>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:7337 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750925AbXALO3Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jan 2007 09:29:25 -0500
To: Richard Knutsson <ricknu-0@student.ltu.se>
In-Reply-To: <45A78ACA.1010600@student.ltu.se>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

That's a good change.
Thanks.
-Amit

On Friday 12 January 2007 18:49, Richard Knutsson wrote:
> Signed-off-by: Richard Knutsson <ricknu-0@student.ltu.se>
> ---
>
> diff --git a/drivers/net/netxen/netxen_nic_main.c
> b/drivers/net/netxen/netxen_nic_main.c index 8a5792f..96e1bee 100644
> --- a/drivers/net/netxen/netxen_nic_main.c
> +++ b/drivers/net/netxen/netxen_nic_main.c
> @@ -1144,7 +1144,7 @@ static int __init netxen_init_module(void)
>  	if ((netxen_workq = create_singlethread_workqueue("netxen")) == 0)
>  		return -ENOMEM;
>
> -	return pci_module_init(&netxen_driver);
> +	return pci_register_driver(&netxen_driver);
>  }
>
>  module_init(netxen_init_module);
