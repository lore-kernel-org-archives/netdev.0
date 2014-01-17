From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] net_sched: act: pick a different type for
 act_xt
Date: Thu, 16 Jan 2014 17:24:42 -0800 (PST)
Message-ID: <20140116.172442.1876893427198735542.davem@davemloft.net>
References: <1389829123-22914-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55822 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750937AbaAQBYm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 20:24:42 -0500
In-Reply-To: <1389829123-22914-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Wed, 15 Jan 2014 15:38:43 -0800

> In tcf_register_action() we check either ->type or ->kind to see if
> there is an existing action registered, but ipt action registers two
> actions with same type but different kinds. They should have different
> types too.
> 
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied.
