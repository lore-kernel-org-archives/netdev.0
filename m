From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv4: avoid passing NULL to inet_putpeer() in
 icmpv4_xrlim_allow()
Date: Mon, 26 Nov 2012 17:25:19 -0500 (EST)
Message-ID: <20121126.172519.1733842286506154861.davem@davemloft.net>
References: <1353819277-2350-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54976 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932140Ab2KZWZV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2012 17:25:21 -0500
In-Reply-To: <1353819277-2350-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Sat, 24 Nov 2012 23:54:37 -0500

> inet_getpeer_v4() can return NULL under OOM conditions, and while
> inet_peer_xrlim_allow() is OK with a NULL peer, inet_putpeer() will
> crash.
> 
> This code path now uses the same idiom as the others from:
> 1d861aa4b3fb08822055345f480850205ffe6170 ("inet: Minimize use of
> cached route inetpeer.").
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>

Applied, thanks a lot Neil.
