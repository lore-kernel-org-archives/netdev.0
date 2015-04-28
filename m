From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] net: sched: act_connmark: don't zap skb->nfct
Date: Tue, 28 Apr 2015 14:03:47 +0200
Message-ID: <20150428120347.GA4306@salvia>
References: <1430220801-21798-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54046 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965345AbbD1L7O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Apr 2015 07:59:14 -0400
Content-Disposition: inline
In-Reply-To: <1430220801-21798-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 28, 2015 at 01:33:21PM +0200, Florian Westphal wrote:
> This action is meant to be passive, i.e. we should not alter
> skb->nfct: If nfct is present just leave it alone.
> 
> Compile tested only.
> 
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>

Acked-by: Pablo Neira Ayuso <pablo@netfilter.org>
