From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 7/9] myri10ge: misc style cleanups
Date: Mon, 27 Jun 2011 09:05:59 -0700
Message-ID: <1309190759.3344.10.camel@Joe-Laptop>
References: <1309187108-12715-1-git-send-email-mason@myri.com>
	 <1309187108-12715-7-git-send-email-mason@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Andrew Gallatin <gallatin@myri.com>
To: Jon Mason <mason@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:3239 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752136Ab1F0QGB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jun 2011 12:06:01 -0400
In-Reply-To: <1309187108-12715-7-git-send-email-mason@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-06-27 at 10:05 -0500, Jon Mason wrote:
> Miscellaneous white space, style, and other cleanups
[]
> diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
[]
> @@ -1538,9 +1538,10 @@ static inline void myri10ge_check_statblock(struct myri10ge_priv *mgp)
>  			} else {
>  				if (netif_msg_link(mgp))
>  					netdev_info(mgp->dev, "link %s\n",
> -					    link_up == MXGEFW_LINK_MYRINET ?
> -					    "mismatch (Myrinet detected)" :
> -					    "down");
> +						    (link_up ==
> +						     MXGEFW_LINK_MYRINET ?
> +						     "mismatch (Myrinet detected)"
> +						     : "down"));

This could be:

				netif_info(mgp, link, mgp->dev, "link %s\n"
					   link_up == MXGEFW_LINK_MYRINET ?
					   "mismatch (Myrinet detected)" :
					   "down");


