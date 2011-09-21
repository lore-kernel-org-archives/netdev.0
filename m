From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH resend] fib:fix BUG_ON in fib_nl_newrule when add new
 fib rule
Date: Wed, 21 Sep 2011 15:17:01 -0400 (EDT)
Message-ID: <20110921.151701.1605320247440880043.davem@davemloft.net>
References: <1315675150-3012-1-git-send-email-wanlong.gao@gmail.com>
	<1315791365-5324-1-git-send-email-wanlong.gao@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	omarapazanadi@gmail.com, gaofeng@cn.fujitsu.com,
	eric.dumazet@gmail.com
To: wanlong.gao@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35929 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751825Ab1IUTRJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2011 15:17:09 -0400
In-Reply-To: <1315791365-5324-1-git-send-email-wanlong.gao@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wanlong Gao <wanlong.gao@gmail.com>
Date: Mon, 12 Sep 2011 09:36:05 +0800

> From: Gao feng <gaofeng@cn.fujitsu.com>
> 
> add new fib rule can cause BUG_ON happen
> the reproduce shell is
> ip rule add pref 38
> ip rule add pref 38
> ip rule add to 192.168.3.0/24 goto 38
> ip rule del pref 38
> ip rule add to 192.168.3.0/24 goto 38
> ip rule add pref 38
> 
> then the BUG_ON will happen
> del BUG_ON and use (ctarget == NULL) identify whether this rule is unresolved
> 
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks a lot.
