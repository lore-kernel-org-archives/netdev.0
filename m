From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][RFC] cxgb4: Not need to hold the adap_rcu_lock lock
 when read adap_rcu_list
Date: Tue, 24 Jun 2014 15:54:10 -0700 (PDT)
Message-ID: <20140624.155410.802407476153586247.davem@davemloft.net>
References: <1403256756-6557-1-git-send-email-rongqing.li@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	hariprasad@chelsio.com, leedom@chelsio.com, greearb@candelatech.com
To: rongqing.li@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54780 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752857AbaFXWyO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2014 18:54:14 -0400
In-Reply-To: <1403256756-6557-1-git-send-email-rongqing.li@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <rongqing.li@windriver.com>
Date: Fri, 20 Jun 2014 17:32:36 +0800

> From: Li RongQing <roy.qing.li@gmail.com> 
> 
> cxgb4_netdev maybe lead to dead lock, since it uses a spin lock, and be called
> in both thread and softirq context, but not disable BH, the lockdep report is
> below; In fact, cxgb4_netdev only reads adap_rcu_list with RCU protection, so
> not need to hold spin lock again.
 ...
> Reported-by: Ben Greear <greearb@candelatech.com>
> Cc: Casey Leedom <leedom@chelsio.com>
> Cc: Hariprasad Shenai <hariprasad@chelsio.com>
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks.

Casey please _do not_ put indentation in front of your Acked-by:,
automated tools like patchwork will not pick it up if you do that.

I'm actually very surprised how much spurious indentation and weird
spacing shows up in some people's postings.  You folks definitely are
using graphical tools to type this stuff in, rather than real pure
text editors.
