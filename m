From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] net_sched: cancel nest attribute on failure
 in tcf_exts_dump()
Date: Wed, 16 Jul 2014 23:51:38 -0700 (PDT)
Message-ID: <20140716.235138.2067858960008875634.davem@davemloft.net>
References: <1405545931-13832-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, cwang@twopensource.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57994 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750928AbaGQGvj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 02:51:39 -0400
In-Reply-To: <1405545931-13832-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Wed, 16 Jul 2014 14:25:30 -0700

> From: Cong Wang <cwang@twopensource.com>
> 
> Like other places, we need to cancel the nest attribute after
> we start. Fortunately the netlink message will not be sent on
> failure, so it's not a big problem at all.
> 
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> Signed-off-by: Cong Wang <cwang@twopensource.com>

Jamal, if you could review these two changes from Cong I'd appreciate
it, thanks!
