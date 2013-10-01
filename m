From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/2] sit: allow to use rtnl ops on fb tunnel
Date: Tue, 01 Oct 2013 12:59:23 -0400 (EDT)
Message-ID: <20131001.125923.700243113980583930.davem@davemloft.net>
References: <524AB26B.1070700@6wind.com>
	<1380643500-5018-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com,
	pshelar@nicira.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55176 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751916Ab3JAQ7Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 12:59:24 -0400
In-Reply-To: <1380643500-5018-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Tue,  1 Oct 2013 18:04:59 +0200

> rtnl ops where introduced by ba3e3f50a0e5 ("sit: advertise tunnel param via
> rtnl"), but I forget to assign rtnl ops to fb tunnels.
> 
> Now that it is done, we must remove the explicit call to
> unregister_netdevice_queue(), because  the fallback tunnel is added to the queue
> in sit_destroy_tunnels() when checking rtnl_link_ops of all netdevices (this
> is valid since commit 5e6700b3bf98 ("sit: add support of x-netns")).
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied and queued up for -stable.

But I imagine since the x-netns changes aren't in various -stable
branches this will need to be adjusted a bit?
