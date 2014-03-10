From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: fq: do not hold qdisc lock while allocating
 memory
Date: Mon, 10 Mar 2014 16:18:30 -0400 (EDT)
Message-ID: <20140310.161830.86859361591992251.davem@davemloft.net>
References: <1394233362.20149.47.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140308.191032.101129109368547659.davem@davemloft.net>
	<1394374706.20149.94.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47095 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753288AbaCJUSc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 16:18:32 -0400
In-Reply-To: <1394374706.20149.94.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 09 Mar 2014 07:18:26 -0700

> On Sat, 2014-03-08 at 19:10 -0500, David Miller wrote:
> 
>> Good point, this patch as-is is fine, so applied.
> 
> I see you applied it in net-next, but it should be in net tree

My bad, I applied it now to 'net' too and queued it up for -stable.
