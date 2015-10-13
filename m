From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/4] tcp: better smp listener behavior
Date: Mon, 12 Oct 2015 19:28:53 -0700 (PDT)
Message-ID: <20151012.192853.2293179655118086493.davem@davemloft.net>
References: <1444341537-20945-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42994 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932118AbbJMCMx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 22:12:53 -0400
In-Reply-To: <1444341537-20945-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Thu,  8 Oct 2015 14:58:53 -0700

> As promised in last patch series, we implement a better SO_REUSEPORT
> strategy, based on cpu hints if given by the application.
> 
> We also moved sk_refcnt out of the cache line containing the lookup
> keys, as it was considerably slowing down smp operations because
> of false sharing. This was simpler than converting listen sockets
> to conventional RCU (to avoid sk_refcnt dirtying)
> 
> Could process 6.0 Mpps SYN instead of 4.2 Mpps on my test server.

Series applied, thanks Eric.
