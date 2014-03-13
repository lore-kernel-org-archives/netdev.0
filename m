From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net_sched: return nla_nest_end() instead of
 skb->len
Date: Thu, 13 Mar 2014 15:39:44 -0400 (EDT)
Message-ID: <20140313.153944.1983172317371654231.davem@davemloft.net>
References: <1394590832-11064-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: yangyingliang@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55612 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754804AbaCMTjr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2014 15:39:47 -0400
In-Reply-To: <1394590832-11064-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yang Yingliang <yangyingliang@huawei.com>
Date: Wed, 12 Mar 2014 10:20:32 +0800

> nla_nest_end() already has return skb->len, so replace
> return skb->len with return nla_nest_end instead().
> 
> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>

Thanks for this simplification, applied.
