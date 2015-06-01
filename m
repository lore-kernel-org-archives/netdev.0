From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] isdn/capi: Use setup_timer
Date: Sun, 31 May 2015 21:36:57 -0700 (PDT)
Message-ID: <20150531.213657.1250786887573503291.davem@davemloft.net>
References: <20150601014015.GA6747@vaishali-Ideapad-Z570>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, julia.lawall@lip6.fr, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: vthakkar1994@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45249 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750987AbbFAEg6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 00:36:58 -0400
In-Reply-To: <20150601014015.GA6747@vaishali-Ideapad-Z570>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vaishali Thakkar <vthakkar1994@gmail.com>
Date: Mon, 1 Jun 2015 07:10:15 +0530

> Use the timer API function setup_timer instead of structure field
> assignments to initialize a timer.
> 
> A simplified version of the Coccinelle semantic patch that performs
> this transformation is as follows:
> 
> @change@
> expression e1, e2, e3, e4, a, b;
> @@
> 
> -init_timer(&e1);
> +setup_timer(&e1, a, b);
> 
> ... when != a = e2
>     when != b = e3
> 
> -e1.data = b;
> ... when != a = e4
> -e1.function = a;
> 
> Signed-off-by: Vaishali Thakkar <vthakkar1994@gmail.com>

Applied, thanks.
