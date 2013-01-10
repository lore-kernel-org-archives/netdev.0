From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: splice: fix an infinite loop in tcp_read_sock()
Date: Thu, 10 Jan 2013 14:37:47 -0800 (PST)
Message-ID: <20130110.143747.1676345092719691710.davem@davemloft.net>
References: <1357837570.27446.2285.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, w@1wt.eu
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34536 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753424Ab3AJWhs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2013 17:37:48 -0500
In-Reply-To: <1357837570.27446.2285.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 10 Jan 2013 09:06:10 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> commit 02275a2ee7c0 (tcp: don't abort splice() after small transfers)
> added a regression.
 ...
> if recv_actor() returns 0, we should stop immediately,
> because looping wont give a chance to drain the pipe.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
