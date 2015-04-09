From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] vxlan: do not exit on error in vxlan_stop()
Date: Wed, 08 Apr 2015 22:48:41 -0400 (EDT)
Message-ID: <20150408.224841.540558293903949631.davem@davemloft.net>
References: <1428529710-19798-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, marcelo.leitner@gmail.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43396 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753864AbbDICsm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 22:48:42 -0400
In-Reply-To: <1428529710-19798-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Wed,  8 Apr 2015 14:48:30 -0700

> We need to clean up vxlan despite vxlan_igmp_leave() fails.
> 
> This fixes the following kernel warning:
...
> Fixes: 56ef9c909b40 ("vxlan: Move socket initialization to within rtnl scope")
> Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied, thanks.
