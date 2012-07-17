From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 0/2] Pull request for 'davem-next.r8169' branch
Date: Tue, 17 Jul 2012 15:46:41 -0700
Message-ID: <1342565201.1898.6.camel@joe2Laptop>
References: <cover.1342562326.git.romieu@fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Hayes Wang <hayeswang@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:42699 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751857Ab2GQWqm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jul 2012 18:46:42 -0400
In-Reply-To: <cover.1342562326.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-07-18 at 00:09 +0200, Francois Romieu wrote:
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c

Hello Francois, just a bit of trivia:

> @@ -865,7 +865,8 @@ static bool rtl_loop_wait(struct rtl8169_private *tp, const struct rtl_cond *c,
>  		if (c->check(tp) == high)
>  			return true;
>  	}
> -	netif_err(tp, drv, tp->dev, c->msg);
> +	netif_err(tp, drv, tp->dev, "%s == %d (loop: %d, delay: %d).\n",
> +		  c->msg, !high, n, d);

Please avoid adding the period to a message before a newline.

$ git grep -E "[^\.]\\\\n\"" drivers/net/ethernet/realtek | wc -l
113
$ git grep -E "\.\\\\n\"" drivers/net/ethernet/realtek | wc -l
12
