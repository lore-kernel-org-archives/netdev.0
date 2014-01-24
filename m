From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH stable 3.7+] fib_frontend: fix possible NULL pointer
 dereference
Date: Fri, 24 Jan 2014 15:52:06 -0800 (PST)
Message-ID: <20140124.155206.1783075688524593121.davem@davemloft.net>
References: <52E0DEA6.3060803@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: socketcan@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40706 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750872AbaAXXwJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jan 2014 18:52:09 -0500
In-Reply-To: <52E0DEA6.3060803@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <socketcan@hartkopp.net>
Date: Thu, 23 Jan 2014 10:19:34 +0100

> The two commits 0115e8e30d (net: remove delay at device dismantle) and
> 748e2d9396a (net: reinstate rtnl in call_netdevice_notifiers()) silently
> removed a NULL pointer check for in_dev since Linux 3.7.
> 
> This patch re-introduces this check as it causes crashing the kernel when
> setting small mtu values on non-ip capable netdevices.
> 
> Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>

Applied and queued up for -stable, thanks.
