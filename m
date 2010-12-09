From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH] connector: add module alias
Date: Thu, 9 Dec 2010 21:47:46 +0300
Message-ID: <20101209184746.GA2476@ioremap.net>
References: <20101209093646.1b5a6abb@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from corega.com.ru ([195.178.208.66]:41122 "EHLO tservice.net.ru"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751720Ab0LISrx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Dec 2010 13:47:53 -0500
Content-Disposition: inline
In-Reply-To: <20101209093646.1b5a6abb@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 09, 2010 at 09:36:46AM -0800, Stephen Hemminger (shemminger@vyatta.com) wrote:
> Since connector can be built as a module and uses netlink socket
> to communicate. The module should have an alias to autoload when socket
> of NETLINK_CONNECTOR type is requested.

Ack, thank you.
David, please apply.

> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> --- a/drivers/connector/connector.c	2010-12-09 09:19:05.549120343 -0800
> +++ b/drivers/connector/connector.c	2010-12-09 09:19:52.795051458 -0800
> @@ -36,6 +36,7 @@
>  MODULE_LICENSE("GPL");
>  MODULE_AUTHOR("Evgeniy Polyakov <zbr@ioremap.net>");
>  MODULE_DESCRIPTION("Generic userspace <-> kernelspace connector.");
> +MODULE_ALIAS_NET_PF_PROTO(PF_NETLINK, NETLINK_CONNECTOR);
>  
>  static struct cn_dev cdev;
>  

-- 
	Evgeniy Polyakov
