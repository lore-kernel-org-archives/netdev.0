From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: show pmtu in route list
Date: Fri, 20 Jul 2012 16:22:15 -0700 (PDT)
Message-ID: <20120720.162215.2278959554536542562.davem@davemloft.net>
References: <1342774928-29301-1-git-send-email-ja@ssi.bg>
	<20120720.111620.1609537308761180.davem@davemloft.net>
	<alpine.LFD.2.00.1207210219470.1893@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56438 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751618Ab2GTXWQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 19:22:16 -0400
In-Reply-To: <alpine.LFD.2.00.1207210219470.1893@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Sat, 21 Jul 2012 02:26:28 +0300 (EEST)

> 	I'll try this weekend to reorganize the seqlock
> usage in tcp_metrics.c and to provide method to feed
> rt_fill_info with values from this cache.

Wouldn't it be better to just export the TCP metrics via it's own
file or netlink facility?

They keying of the TCP metrics is completely different from how routes
are key'd.  So I see little value in creating the illusion that these
two things live in the same keying domain.

The routing cache will be completely gone and /proc/net/rt_cache will
be an empty file.
