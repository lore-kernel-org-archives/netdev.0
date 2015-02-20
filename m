From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Remove state argument from skb_find_text()
Date: Fri, 20 Feb 2015 17:22:33 -0500 (EST)
Message-ID: <20150220.172233.1250644959779215916.davem@davemloft.net>
References: <1424301408-3659-1-git-send-email-prtvar.b@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@suug.ch,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	dan.carpenter@oracle.com
To: prtvar.b@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47413 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754613AbbBTWYQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 17:24:16 -0500
In-Reply-To: <1424301408-3659-1-git-send-email-prtvar.b@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bojan Prtvar <prtvar.b@gmail.com>
Date: Thu, 19 Feb 2015 00:16:48 +0100

> Although it is clear that textsearch state is intentionally passed
> to skb_find_text() as uninitialized argument, it was never used by
> the callers. Therefore, we can simplify skb_find_text() by making it
> local variable.
> 
> Signed-off-by: Bojan Prtvar <prtvar.b@gmail.com>

Although I partially agree with Pablo's response these interfaces were
designed to be able to hold state across calls, nobody uses them this
way yet.  So this change is fine and we can resurrect the argument
if a use appears in the future.

However, your patch doesn't apply cleanly, please respin.
