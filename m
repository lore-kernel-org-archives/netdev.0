From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] sched, cls: check if we could overwrite
 actions when changing a filter
Date: Sun, 27 Apr 2014 23:42:52 -0400 (EDT)
Message-ID: <20140427.234252.1163561125417356203.davem@davemloft.net>
References: <1398459246-15550-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, cwang@twopensource.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36352 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752330AbaD1Dmx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Apr 2014 23:42:53 -0400
In-Reply-To: <1398459246-15550-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Fri, 25 Apr 2014 13:54:06 -0700

> From: Cong Wang <cwang@twopensource.com>
> 
> When actions are attached to a filter, they are a part of the filter
> itself, so when changing a filter we should allow to overwrite the actions
> inside as well.
> 
> In my specific case, when I tried to _append_ a new action to an existing
> filter which already has an action, I got EEXIST since kernel refused
> to overwrite the existing one in kernel.
> 
> This patch checks if we are changing the filter checking NLM_F_CREATE flag
> (Sigh, filters don't use NLM_F_REPLACE...) and then passes the boolean down
> to actions. This fixes the problem above.
> 
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> Signed-off-by: Cong Wang <cwang@twopensource.com>
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

Applied.
