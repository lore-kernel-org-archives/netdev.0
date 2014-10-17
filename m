From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: dst_entry leak in ip_send_unicast_reply()
Date: Fri, 17 Oct 2014 11:59:32 -0400 (EDT)
Message-ID: <20141017.115932.740288542547693461.davem@davemloft.net>
References: <543E6762.9090807@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: vvs@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40696 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751289AbaJQP7e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2014 11:59:34 -0400
In-Reply-To: <543E6762.9090807@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasily Averin <vvs@parallels.com>
Date: Wed, 15 Oct 2014 16:24:02 +0400

> Fixes: 2e77d89b2fa8 ("net: avoid a pair of dst_hold()/dst_release() in ip_append_data()")
> 
> ip_setup_cork() called inside ip_append_data() steals dst entry from rt to cork
> and in case errors in __ip_append_data() nobody frees stolen dst entry
> 
> Signed-off-by: Vasily Averin <vvs@parallels.com>

Please, in the future, put the Fixes: tag first in the list of signoffs.

Eric, please review this change, it looks good to me.
