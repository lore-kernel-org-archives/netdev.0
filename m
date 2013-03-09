From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] net: Kill link between CSUM and SG
 features.
Date: Sat, 09 Mar 2013 16:10:58 -0500 (EST)
Message-ID: <20130309.161058.362205341442566903.davem@davemloft.net>
References: <1362684481-1789-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, jesse@nicira.com
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40891 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751079Ab3CIVKw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Mar 2013 16:10:52 -0500
In-Reply-To: <1362684481-1789-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Thu,  7 Mar 2013 11:28:01 -0800

> Earlier SG was unset if CSUM was not available for given device to
> force skb copy to avoid sending inconsistent csum.
> Commit c9af6db4c11c (net: Fix possible wrong checksum generation)
> added explicit flag to force copy to fix this issue.  Therefore
> there is no need to link SG and CSUM, following patch kills this
> link between there two features.
> 
> This patch is also required following patch in series.
> 
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Applied.
