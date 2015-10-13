From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 0/4] tcp: better smp listener behavior
Date: Mon, 12 Oct 2015 19:29:19 -0700 (PDT)
Message-ID: <20151012.192919.95216196401891250.davem@davemloft.net>
References: <1444358004-26483-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42998 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932118AbbJMCNU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 22:13:20 -0400
In-Reply-To: <1444358004-26483-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Thu,  8 Oct 2015 19:33:20 -0700

> As promised in last patch series, we implement a better SO_REUSEPORT
> strategy, based on cpu affinities if selected by the application.
> 
> We also moved sk_refcnt out of the cache line containing the lookup
> keys, as it was considerably slowing down smp operations because
> of false sharing. This was simpler than converting listen sockets
> to conventional RCU (to avoid sk_refcnt dirtying)
> 
> Could process 6.0 Mpps SYN instead of 4.2 Mpps on my test server.

Just clarifying that I applied this v3 not v2 which I just replied
to by accident :-)
