From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Remove casts to same type
Date: Mon, 04 Jun 2012 11:45:33 -0400 (EDT)
Message-ID: <20120604.114533.1720204611284591292.davem@davemloft.net>
References: <4b3738493b23bc386d3372012faa8cd3672a138d.1338780551.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40425 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753946Ab2FDPpe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2012 11:45:34 -0400
In-Reply-To: <4b3738493b23bc386d3372012faa8cd3672a138d.1338780551.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Sun,  3 Jun 2012 20:41:40 -0700

> Adding casts of objects to the same type is unnecessary
> and confusing for a human reader.
> 
> For example, this cast:
> 
> 	int y;
> 	int *p = (int *)&y;
> 
> I used the coccinelle script below to find and remove these
> unnecessary casts.  I manually removed the conversions this
> script produces of casts with __force and __user.
> 
> @@
> type T;
> T *p;
> @@
> 
> -	(T *)p
> +	p
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied to net-next, thanks Joe.
