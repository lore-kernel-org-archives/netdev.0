From: David Miller <davem@davemloft.net>
Subject: Re: [RESEND PATCH net-next] ipv6/multipath: remove flag NLM_F_EXCL
 after the first nexthop
Date: Fri, 02 Nov 2012 21:38:57 -0400 (EDT)
Message-ID: <20121102.213857.2276553238313329445.davem@davemloft.net>
References: <50896D47.7030500@6wind.com>
	<1351846702-4982-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org, joe@perches.com,
	bernat@luffy.cx, eric.dumazet@gmail.com, yoshfuji@linux-ipv6.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49343 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755590Ab2KCBi7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Nov 2012 21:38:59 -0400
In-Reply-To: <1351846702-4982-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Fri,  2 Nov 2012 09:58:22 +0100

> fib6_add_rt2node() will reject the nexthop if this flag is set, so
> we perform the check only for the first nexthop.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

It seems a bit hackish, but I don't have any better ideas, so
applied, thanks.
