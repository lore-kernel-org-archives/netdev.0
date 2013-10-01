From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/2] ip6tnl: allow to use rtnl ops on fb tunnel
Date: Tue, 01 Oct 2013 12:59:42 -0400 (EDT)
Message-ID: <20131001.125942.775476054819333568.davem@davemloft.net>
References: <524AB26B.1070700@6wind.com>
	<1380643500-5018-1-git-send-email-nicolas.dichtel@6wind.com>
	<1380643500-5018-2-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com,
	pshelar@nicira.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55183 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752238Ab3JAQ7n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 12:59:43 -0400
In-Reply-To: <1380643500-5018-2-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Tue,  1 Oct 2013 18:05:00 +0200

> rtnl ops where introduced by c075b13098b3 ("ip6tnl: advertise tunnel param via
> rtnl"), but I forget to assign rtnl ops to fb tunnels.
> 
> Now that it is done, we must remove the explicit call to
> unregister_netdevice_queue(), because  the fallback tunnel is added to the queue
> in ip6_tnl_destroy_tunnels() when checking rtnl_link_ops of all netdevices (this
> is valid since commit 0bd8762824e7 ("ip6tnl: add x-netns support")).
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied and queued up for -stable, and I have similar concerns about
the backport issues.

Thanks.
