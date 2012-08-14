From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][XFRM][v3] Replace rwlock on xfrm_policy_afinfo with rcu
Date: Tue, 14 Aug 2012 14:58:10 -0700 (PDT)
Message-ID: <20120814.145810.1233583454786502352.davem@davemloft.net>
References: <1344842549-25923-1-git-send-email-Priyanka.Jain@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Priyanka.Jain@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38647 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750756Ab2HNV6L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2012 17:58:11 -0400
In-Reply-To: <1344842549-25923-1-git-send-email-Priyanka.Jain@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Priyanka Jain <Priyanka.Jain@freescale.com>
Date: Mon, 13 Aug 2012 12:52:29 +0530

> xfrm_policy_afinfo is read mosly data structure.
> Write on xfrm_policy_afinfo is done only at the
> time of configuration.
> So rwlocks can be safely replaced with RCU.
> 
> RCUs usage optimizes the performance.
> 
> Signed-off-by: Priyanka Jain <Priyanka.Jain@freescale.com>

Applied, thanks.
