From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v3 1/1] net: sched: Introduce connmark action
Date: Mon, 19 Jan 2015 16:02:23 -0500 (EST)
Message-ID: <20150119.160223.1328042503373891210.davem@davemloft.net>
References: <1421616915-5377-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nbd@openwrt.org, pablo@netfilter.org,
	fw@strlen.de, jiri@resnulli.us, cwang@twopensource.com
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34724 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750953AbbASVCZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2015 16:02:25 -0500
In-Reply-To: <1421616915-5377-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Sun, 18 Jan 2015 16:35:14 -0500

> From: Felix Fietkau <nbd@openwrt.org>
> 
> This tc action allows you to retrieve the connection tracking mark
> This action has been used heavily by openwrt for a few years now.
> 
> There are known limitations currently:
> 
> doesn't work for initial packets, since we only query the ct table.
>   Fine given use case is for returning packets
> 
> no implicit defrag.
>   frags should be rare so fix later..
> 
> won't work for more complex tasks, e.g. lookup of other extensions
>   since we have no means to store results
> 
> we still have a 2nd lookup later on via normal conntrack path.
> This shouldn't break anything though since skb->nfct isn't altered.
> 
> V2:
> remove unnecessary braces (Jiri)
> change the action identifier to 14 (Jiri)
> Fix some stylistic issues caught by checkpatch
> V3:
> Move module params to bottom (Cong)
> Get rid of tcf_hashinfo_init and friends and conform to newer API (Cong)

Applied, thanks Jamal.
