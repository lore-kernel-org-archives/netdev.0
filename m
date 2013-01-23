From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] netpoll: fix an uninitialized variable
Date: Tue, 22 Jan 2013 23:22:59 -0500 (EST)
Message-ID: <20130122.232259.1146207542642611215.davem@davemloft.net>
References: <1358912351-14835-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60460 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752926Ab3AWEXF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 23:23:05 -0500
In-Reply-To: <1358912351-14835-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Wed, 23 Jan 2013 11:39:11 +0800

> From: Cong Wang <amwang@redhat.com>
> 
> Fengguang reported:
> 
>    net/core/netpoll.c: In function 'netpoll_setup':
>    net/core/netpoll.c:1049:6: warning: 'err' may be used uninitialized in this function [-Wmaybe-uninitialized]
> 
> in !CONFIG_IPV6 case, we may error out without initializing
> 'err'.
> 
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Applied.
