From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/flow: remove sleeping and deferral mechanism from
 flow_cache_flush
Date: Tue, 27 Sep 2011 15:31:32 -0400 (EDT)
Message-ID: <20110927.153132.900366550174236643.davem@davemloft.net>
References: <1317056956-23644-1-git-send-email-madalin.bucur@freescale.com>
	<20110927.152836.1747700807304689813.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, timo.teras@iki.fi
To: madalin.bucur@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56170 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752221Ab1I0Tcp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2011 15:32:45 -0400
In-Reply-To: <20110927.152836.1747700807304689813.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Tue, 27 Sep 2011 15:28:36 -0400 (EDT)

> afinfo->garbage_collect is the only other place __xfrm_garbage_collect
> is referenced, and that is completely unused and should thus be deleted
> (I'll take care of that in net-next).

Nevermind I see how these are referenced directly via xfrm4_policy.c
and xfrm6_policy.c, sigh...
