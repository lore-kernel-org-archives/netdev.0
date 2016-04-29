From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ip_tunnel: fix preempt warning in ip tunnel
 creation/updating
Date: Fri, 29 Apr 2016 14:11:33 -0400 (EDT)
Message-ID: <20160429.141133.1960480450373039914.davem@davemloft.net>
References: <b21056e2495c485a2084d058d03e1f95480b3510.1461834203.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, tgraf@suug.ch,
	pshelar@nicira.com, jbenc@redhat.com, hannes@stressinduktion.org,
	sergei.shtylyov@cogentembedded.com, tom@herbertland.com,
	eric.dumazet@gmail.com
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54450 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751710AbcD2SLm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 14:11:42 -0400
In-Reply-To: <b21056e2495c485a2084d058d03e1f95480b3510.1461834203.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Thu, 28 Apr 2016 11:04:51 +0200

> After the commit e09acddf873b ("ip_tunnel: replace dst_cache with generic
> implementation"), a preemption debug warning is triggered on ip4
> tunnels updating; the dst cache helper needs to be invoked in unpreemptible
> context.
> 
> We don't need to load the cache on tunnel update, so this commit fixes
> the warning replacing the load with a dst cache reset, which is
> preempt safe.
> 
> Fixes: e09acddf873b ("ip_tunnel: replace dst_cache with generic
> implementation")
> 
> Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Applied, thanks Paolo.
