From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] ipv6: Kill ipv6 dependency of
 icmpv6_send().
Date: Mon, 29 Apr 2013 13:55:11 -0400 (EDT)
Message-ID: <20130429.135511.2204808127391765068.davem@davemloft.net>
References: <1366924110-3397-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59666 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758630Ab3D2RzO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 13:55:14 -0400
In-Reply-To: <1366924110-3397-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Thu, 25 Apr 2013 14:08:30 -0700

> Following patch adds icmp-registration module for ipv6.  It allows
> ipv6 protocol to register icmp_sender which is used for sending
> ipv6 icmp msgs.  This extra layer allows us to kill ipv6 dependency
> for sending icmp packets.
> 
> This patch also fixes ip_tunnel compilation problem when ip_tunnel
> is statically compiled in kernel but ipv6 is module
> 
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Applied, thanks.
