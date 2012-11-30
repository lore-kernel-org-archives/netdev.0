From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: unify logic evaluating inet6_dev's accept_ra
 property
Date: Fri, 30 Nov 2012 12:09:43 -0500 (EST)
Message-ID: <20121130.120943.1397811156693287841.davem@davemloft.net>
References: <1354181179-16294-1-git-send-email-shmulik.ladkani@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org, tgraf@suug.ch,
	tore@fud.no
To: shmulik.ladkani@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44517 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758559Ab2K3RJo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2012 12:09:44 -0500
In-Reply-To: <1354181179-16294-1-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Date: Thu, 29 Nov 2012 11:26:19 +0200

> +	/*
> +	 * If forwarding is enabled, RA are not accepted unless the special
> +	 * hybrid mode (accept_ra=2) is enabled.
> +	 */

Please format this comment correctly, in the networking we use
the style:

	/* That looks
	 * like this.
	 */

	/*
	 * Not
	 * like this.
	 */

Thanks.
