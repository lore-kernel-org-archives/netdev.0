From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: xfrm, use correct rcu dereference helper
Date: Sat, 18 Aug 2012 14:08:06 -0700 (PDT)
Message-ID: <20120818.140806.1408326124840020051.davem@davemloft.net>
References: <1345210716-24556-1-git-send-email-jslaby@suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jirislaby@gmail.com,
	linux-kernel@vger.kernel.org, Priyanka.Jain@freescale.com
To: jslaby@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35267 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751581Ab2HRVIJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Aug 2012 17:08:09 -0400
In-Reply-To: <1345210716-24556-1-git-send-email-jslaby@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Slaby <jslaby@suse.cz>
Date: Fri, 17 Aug 2012 15:38:36 +0200

> Use rcu_dereference_bh while holding bh rcu lock. Otherwise we get:
> ===============================
> [ INFO: suspicious RCU usage. ]
> 3.6.0-rc1-next-20120816+ #10 Not tainted
> -------------------------------
> net/xfrm/xfrm_policy.c:2504 suspicious rcu_dereference_check() usage!
> 
> Signed-off-by: Jiri Slaby <jslaby@suse.cz>
> Cc: Priyanka Jain <Priyanka.Jain@freescale.com>

Should already be fixed in net-next for at least a whole day now.
