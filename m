From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] tcp: syncookies: do not use getnstimeofday()
Date: Thu, 20 Mar 2014 16:23:10 -0400 (EDT)
Message-ID: <20140320.162310.224427654050265618.davem@davemloft.net>
References: <1395261524.9114.60.camel@edumazet-glaptop2.roam.corp.google.com>
	<1395263181.9114.69.camel@edumazet-glaptop2.roam.corp.google.com>
	<1395288141.9114.82.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51112 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758197AbaCTUXM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 16:23:12 -0400
In-Reply-To: <1395288141.9114.82.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 19 Mar 2014 21:02:21 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> While it is true that getnstimeofday() uses about 40 cycles if TSC
> is available, it can use 1600 cycles if hpet is the clocksource.
> 
> Switch to get_jiffies_64(), as this is more than enough, and
> go back to 60 seconds periods.
> 
> Fixes: 8c27bd75f04f ("tcp: syncookies: reduce cookie lifetime to 128 seconds")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
