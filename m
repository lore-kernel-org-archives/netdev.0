From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: sched: add ipset ematch
Date: Thu, 12 Jul 2012 08:00:25 -0700 (PDT)
Message-ID: <20120712.080025.7588426314181431.davem@davemloft.net>
References: <1342040217-5637-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kadlec@blackhole.kfki.hu
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57298 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932528Ab2GLPA0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 11:00:26 -0400
In-Reply-To: <1342040217-5637-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Wed, 11 Jul 2012 22:56:57 +0200

> Can be used to match packets against netfilter ip sets created via ipset(8).
> skb->sk_iif is used as 'incoming interface', skb->dev is 'outgoing interface'.
> 
> Since ipset is usually called from netfilter, the ematch
> initializes a fake xt_action_param, pulls the ip header into the
> linear area and also sets skb->data to the IP header (otherwise
> matching Layer 4 set types doesn't work).
> 
> Tested-by: Mr Dash Four <mr.dash.four@googlemail.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied, thanks.
