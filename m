From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net ipv4 ipconfig: use preferred log methods
Date: Mon, 28 Sep 2015 22:24:09 -0700 (PDT)
Message-ID: <20150928.222409.1641594777817922710.davem@davemloft.net>
References: <1443175110-23498-1-git-send-email-bst@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org, trivial@kernel.org,
	kernel@pengutronix.de
To: bst@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53925 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753588AbbI2FYK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 01:24:10 -0400
In-Reply-To: <1443175110-23498-1-git-send-email-bst@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bastian Stender <bst@pengutronix.de>
Date: Fri, 25 Sep 2015 11:58:30 +0200

> @@ -69,7 +69,7 @@
>  #undef IPCONFIG_DEBUG
>  
>  #ifdef IPCONFIG_DEBUG
> -#define DBG(x) printk x
> +#define DBG(x) pr_debug(x)
>  #else
>  #define DBG(x) do { } while(0)
>  #endif

I agree with Stephen, just get rid of this and use pr_debug()
unconditionally.
