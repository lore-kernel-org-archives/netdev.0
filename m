From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] ipv6: restore the behavior of ipv6_sock_ac_drop()
Date: Sun, 07 Sep 2014 16:10:32 -0700 (PDT)
Message-ID: <20140907.161032.428676807612508937.davem@davemloft.net>
References: <1409952780-24471-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sd@queasysnail.net
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56485 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752672AbaIGXKd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Sep 2014 19:10:33 -0400
In-Reply-To: <1409952780-24471-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Fri,  5 Sep 2014 14:33:00 -0700

> It is possible that the interface is already gone after joining
> the list of anycast on this interface as we don't hold a refcount
> for the device, in this case we are safe to ignore the error.
> 
> What's more important, for API compatibility we should not
> change this behavior for applications even if it were correct.
> 
> Fixes: commit a9ed4a2986e13011 ("ipv6: fix rtnl locking in setsockopt for anycast and multicast")
> Cc: Sabrina Dubroca <sd@queasysnail.net>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied, thanks.
