From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: mv643xx_eth: Use setup_timer
Date: Sun, 31 May 2015 21:23:49 -0700 (PDT)
Message-ID: <20150531.212349.1040388068581621723.davem@davemloft.net>
References: <20150601040602.GA3767@vaishali-Ideapad-Z570>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sebastian.hesselbarth@gmail.com, julia.lawall@lip6.fr,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: vthakkar1994@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45123 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754718AbbFAEYV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 00:24:21 -0400
In-Reply-To: <20150601040602.GA3767@vaishali-Ideapad-Z570>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vaishali Thakkar <vthakkar1994@gmail.com>
Date: Mon, 1 Jun 2015 09:36:02 +0530

> Use the timer API function setup_timer instead of structure field
> assignments to initialize a timer.
> 
> A simplified version of the Coccinelle semantic patch that performs
> this transformation is as follows:
> 
> @change@
> expression e, func, da;
> @@
> 
> -init_timer (&e);
> +setup_timer (&e, func, da);
> -e.data = da;
> -e.function = func;
> 
> Signed-off-by: Vaishali Thakkar <vthakkar1994@gmail.com>

Applied to net-next, thanks.
