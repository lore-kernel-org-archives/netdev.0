From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pppoe: drop pppoe device in pppoe_unbind_sock_work
Date: Mon, 11 May 2015 12:58:47 -0400 (EDT)
Message-ID: <20150511.125847.1599775899483403147.davem@davemloft.net>
References: <1431205718-9603-1-git-send-email-nbd@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nbd@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35512 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752069AbbEKQ6w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 12:58:52 -0400
In-Reply-To: <1431205718-9603-1-git-send-email-nbd@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Fietkau <nbd@openwrt.org>
Date: Sat,  9 May 2015 23:08:38 +0200

> After receiving a PADT and the socket is closed, user space will no
> longer drop the reference to the pppoe device.
> This leads to errors like this:
> 
> [  488.570000] unregister_netdevice: waiting for eth0.2 to become free. Usage count = 2
> 
> Fixes: 287f3a943fe ("pppoe: Use workqueue to die properly when a PADT is received")
> Signed-off-by: Felix Fietkau <nbd@openwrt.org>

Applied, thanks Felix.
