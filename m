From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][XFRM] Replace rwlock on xfrm_policy_afinfo with rcu
Date: Tue, 07 Aug 2012 16:21:38 -0700 (PDT)
Message-ID: <20120807.162138.5000306557864030.davem@davemloft.net>
References: <1344316904-2544-1-git-send-email-Priyanka.Jain@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Priyanka.Jain@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34171 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757275Ab2HGXVj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2012 19:21:39 -0400
In-Reply-To: <1344316904-2544-1-git-send-email-Priyanka.Jain@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Priyanka Jain <Priyanka.Jain@freescale.com>
Date: Tue, 7 Aug 2012 10:51:44 +0530

> xfrm_policy_afinfo is read mosly data structure.
> Write on xfrm_policy_afinfo is done only at the
> time of configuration.
> So rwlocks can be safely replaced with RCU.
> 
> RCUs usage optimizes the performance.
> 
> Signed-off-by: Priyanka Jain <Priyanka.Jain@freescale.com>

This patch doesn't apply to the net-next tree, please respin.

Also:

> -			xfrm_policy_afinfo[afinfo->family] = NULL;
> +			rcu_assign_pointer(xfrm_policy_afinfo[afinfo->family],
> +				NULL);

Indent that NULL argument properly, it must line up with the first
column after the openning '(' on the previous line.
