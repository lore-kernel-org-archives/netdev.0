From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atm: br2684: Fix excessive queue bloat
Date: Sun, 25 Nov 2012 16:09:33 -0500 (EST)
Message-ID: <20121125.160933.2139090715980641530.davem@davemloft.net>
References: <1353715292.26346.237.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, blogic@openwrt.org, dave.taht@gmail.com,
	krzysiek@podlesie.net, chas@cmf.nrl.navy.mil
To: dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40734 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753390Ab2KYVJi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Nov 2012 16:09:38 -0500
In-Reply-To: <1353715292.26346.237.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Woodhouse <dwmw2@infradead.org>
Date: Sat, 24 Nov 2012 00:01:32 +0000

> +	/* Allow two packets in the ATM queue. One actually being sent, and one
> +	   for the ATM 'TX done' handler to send. It shouldn't take long to get
> +	   the next one from the netdev queue, when we need it. More than that
> +	   would be bufferbloat. */

Please format this:

	/* Like
	 * this.
	 */

and I'll apply this, thanks.
