From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sched: act_connmark: don't zap skb->nfct
Date: Wed, 29 Apr 2015 14:57:01 -0400 (EDT)
Message-ID: <20150429.145701.2285841701248872564.davem@davemloft.net>
References: <1430220801-21798-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50188 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751270AbbD2S5D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 14:57:03 -0400
In-Reply-To: <1430220801-21798-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Tue, 28 Apr 2015 13:33:21 +0200

> This action is meant to be passive, i.e. we should not alter
> skb->nfct: If nfct is present just leave it alone.
> 
> Compile tested only.
> 
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied.
