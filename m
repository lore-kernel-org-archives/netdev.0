From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] ipv6: introduce ip6tunnel_xmit() helper
Date: Sun, 10 Mar 2013 16:54:13 -0400 (EDT)
Message-ID: <20130310.165413.325088853996732471.davem@davemloft.net>
References: <1362906039-8236-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, pshelar@nicira.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53372 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751334Ab3CJUyF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Mar 2013 16:54:05 -0400
In-Reply-To: <1362906039-8236-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Sun, 10 Mar 2013 17:00:39 +0800

> From: Cong Wang <xiyou.wangcong@gmail.com>
> 
> Similar to iptunnel_xmit(), group these operations into a
> helper function.
> 
> This by the way fixes the missing u64_stats_update_begin()
> and u64_stats_update_end() for 32 bit arch.
> 
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Pravin B Shelar <pshelar@nicira.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Looks good, applied, thanks.
