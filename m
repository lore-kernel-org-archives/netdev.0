From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: remove improper preemption check in
 tcp_xmit_probe_skb()
Date: Wed, 21 Oct 2015 19:30:59 -0700 (PDT)
Message-ID: <20151021.193059.700841656233671580.davem@davemloft.net>
References: <1445287894-2248-1-git-send-email-renatow@taghos.com.br>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, xemul@parallels.com,
	renatow@taghos.com.br
To: renatowestphal@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49941 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752456AbbJVCOd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 22:14:33 -0400
In-Reply-To: <1445287894-2248-1-git-send-email-renatow@taghos.com.br>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Renato Westphal <renatowestphal@gmail.com>
Date: Mon, 19 Oct 2015 18:51:34 -0200

> Commit e520af48c7e5a introduced the following bug when setting the
> TCP_REPAIR sockoption:
 ...
> Since tcp_xmit_probe_skb() can be called from process context, use
> NET_INC_STATS() instead of NET_INC_STATS_BH().
> 
> Signed-off-by: Renato Westphal <renatow@taghos.com.br>

Applied and queued up for -stable, thanks.
