From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/17] net: snmp: update SNMP methods
Date: Wed, 27 Apr 2016 22:48:46 -0400 (EDT)
Message-ID: <20160427.224846.278682260216107809.davem@davemloft.net>
References: <1461800683-25034-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57384 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752041AbcD1Csu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 22:48:50 -0400
In-Reply-To: <1461800683-25034-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Wed, 27 Apr 2016 16:44:26 -0700

> In the old days (before linux-3.0), SNMP counters were duplicated,
> one set for user context, and anther one for BH context.
> 
> After commit 8f0ea0fe3a03 ("snmp: reduce percpu needs by 50%")
> we have a single copy, and what really matters is preemption being
> enabled or disabled, since we use this_cpu_inc() or __this_cpu_inc()
> respectively.
> 
> This patch series kills the obsolete STATS_USER() helpers,
> and rename all XXX_BH() helpers to __XXX() ones, to more
> closely match conventions used to update per cpu variables.
> 
> This is probably going to hurt maintainers job for a while,
> since cherry-picks will not be clean, but this had to be
> cleaned at one point. I am so sorry guys.

Looks good to me, series applied, thanks Eric.
