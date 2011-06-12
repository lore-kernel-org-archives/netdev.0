From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 13/13] ixgbe: use per NUMA node lock for FCoE DDP
Date: Sat, 11 Jun 2011 19:00:39 -0700 (PDT)
Message-ID: <20110611.190039.1761060311291121701.davem@davemloft.net>
References: <1307761341-5267-14-git-send-email-jeffrey.t.kirsher@intel.com>
	<1307769482.2872.62.camel@edumazet-laptop>
	<1307770931.2872.70.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, vasu.dev@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40173 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753590Ab1FLCAo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2011 22:00:44 -0400
In-Reply-To: <1307770931.2872.70.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 11 Jun 2011 07:42:11 +0200

> This patch seems overkill to me, have you tried the more simple way I
> did in commit 79640a4ca6955e3ebdb7038508fa7a0cd7fa5527
> (net: add additional lock to qdisc to increase throughput )
> 
> (remember you must place ->busylock in a separate cache line, to not
> slow down the two cpus that have access to ->lock)
> 
> struct ixgbe_fcoe could probably be more carefuly reordered to lower
> false sharing
> 
> I kindly ask you guys provide actual perf numbers between
> 
> 1) before any patch
> 2) After your multilevel per numanode locks
> 3) A more simple way (my suggestion of adding a single 'busylock')

Jeff, please sort out these issues with Eric and resend your pull
request once things are resolved.

Thanks!
