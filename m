From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/2] ipv6: fix a refcnt leak with peer addr
Date: Fri, 05 Sep 2014 17:13:47 -0700 (PDT)
Message-ID: <20140905.171347.1273847652821486122.davem@davemloft.net>
References: <1409781562-4191-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57764 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750968AbaIFANs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 20:13:48 -0400
In-Reply-To: <1409781562-4191-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Wed,  3 Sep 2014 23:59:21 +0200

> There is no reason to take a refcnt before deleting the peer address route.
> It's done some lines below for the local prefix route because
> inet6_ifa_finish_destroy() will release it at the end.
> For the peer address route, we want to free it right now.
> 
> This bug has been introduced by commit
> caeaba79009c ("ipv6: add support of peer address").
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied.
