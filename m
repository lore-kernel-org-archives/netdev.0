From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] ipv4: move local_port_range out of
 CONFIG_SYSCTL
Date: Thu, 08 May 2014 22:52:35 -0400 (EDT)
Message-ID: <20140508.225235.829615217774430628.davem@davemloft.net>
References: <1399399370-7849-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, romieu@fr.zoreil.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32871 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754353AbaEICwh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2014 22:52:37 -0400
In-Reply-To: <1399399370-7849-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Tue,  6 May 2014 11:02:49 -0700

> From: Cong Wang <xiyou.wangcong@gmail.com>
> 
> When CONFIG_SYSCTL is not set, ip_local_port_range should still work,
> just that no one can change it. Therefore we should move it out of sysctl_inet.c.
> Also, rename it to ->ip_local_ports instead.
> 
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Francois Romieu <romieu@fr.zoreil.com>
> Reported-by: Stefan de Konink <stefan@konink.de>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied to 'net'.
