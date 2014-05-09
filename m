From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] ping: move ping_group_range out of
 CONFIG_SYSCTL
Date: Thu, 08 May 2014 22:52:45 -0400 (EDT)
Message-ID: <20140508.225245.2181997476907528928.davem@davemloft.net>
References: <1399399370-7849-1-git-send-email-xiyou.wangcong@gmail.com>
	<1399399370-7849-2-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, romieu@fr.zoreil.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32875 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932253AbaEICwq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2014 22:52:46 -0400
In-Reply-To: <1399399370-7849-2-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Tue,  6 May 2014 11:02:50 -0700

> From: Cong Wang <xiyou.wangcong@gmail.com>
> 
> Similarly, when CONFIG_SYSCTL is not set, ping_group_range should still
> work, just that no one can change it. Therefore we should move it out of
> sysctl_net_ipv4.c. And, it should not share the same seqlock with
> ip_local_port_range.
> 
> BTW, rename it to ->ping_group_range instead.
> 
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Francois Romieu <romieu@fr.zoreil.com>
> Reported-by: Stefan de Konink <stefan@konink.de>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Also applied to 'net', thanks.
