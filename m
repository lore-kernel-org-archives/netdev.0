From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp_v4_send_reset: binding oif to iif in no sock case
Date: Sat, 04 Feb 2012 16:26:02 -0500 (EST)
Message-ID: <20120204.162602.1922697409850241775.davem@davemloft.net>
References: <RE:_[PATCH]_tcp:_RST:_binding_oif_to_iif_for_tcp_v4>
	<1328390556-14906-1-git-send-email-shawn.lu@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, xiaoclu@gmail.com
To: shawn.lu@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36145 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752956Ab2BDV0I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2012 16:26:08 -0500
In-Reply-To: <1328390556-14906-1-git-send-email-shawn.lu@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shawn Lu <shawn.lu@ericsson.com>
Date: Sat, 4 Feb 2012 13:22:36 -0800

> +	/*
> +	 * When socket is gone, all binding information is lost.
> +	 * routing might fail in this case. using iif for oif to
> +	 * make sure we can deliver it
> +	 */

Comment is poorly formatted, and I'm getting tired of teaching
people

	/* That comments are formatted like
	 * this.
	 */

	/*
	 * Not like this.
	 */

or do you have infinite vertical lines on your monitor so that
this empty "/*" line has no impact on your screen real estate
like it does for the rest of us?
