From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][XFRM][v2] Replace rwlock on xfrm_policy_afinfo with rcu
Date: Thu, 09 Aug 2012 16:15:08 -0700 (PDT)
Message-ID: <20120809.161508.1611476184890758249.davem@davemloft.net>
References: <1344493315-2505-1-git-send-email-Priyanka.Jain@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Priyanka.Jain@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33328 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754131Ab2HIXPK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2012 19:15:10 -0400
In-Reply-To: <1344493315-2505-1-git-send-email-Priyanka.Jain@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Priyanka Jain <Priyanka.Jain@freescale.com>
Date: Thu, 9 Aug 2012 11:51:55 +0530

> +	local_bh_disable();
> +	rcu_read_lock();

This is "rcu_read_lock_bh()"

Also I do not believe you addressed any of Eric Dumazet's feedback.
