From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] act_mirred: clear sender cpu before sending to tx
Date: Thu, 08 Oct 2015 05:05:41 -0700 (PDT)
Message-ID: <20151008.050541.1181539504898578846.davem@davemloft.net>
References: <1444177427-5603-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, jhs@mojatatu.com,
	cwang@twopensource.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60946 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756676AbbJHLty (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 07:49:54 -0400
In-Reply-To: <1444177427-5603-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Tue,  6 Oct 2015 17:23:47 -0700

> Similar to commit c29390c6dfee ("xps: must clear sender_cpu before forwarding")
> the skb->sender_cpu needs to be cleared when moving from Rx
> Tx, otherwise kernel could crash.
> 
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <cwang@twopensource.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied and queued up for -stable.
