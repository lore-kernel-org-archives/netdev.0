From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/7 net-next] tg3: Change default number of tx rings to
 1.
Date: Thu, 27 Sep 2012 19:23:45 -0400 (EDT)
Message-ID: <20120927.192345.2124577537241070059.davem@davemloft.net>
References: <1348698769-760-5-git-send-email-mchan@broadcom.com>
	<1348698769-760-6-git-send-email-mchan@broadcom.com>
	<1348698769-760-7-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59572 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755299Ab2I0XXq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2012 19:23:46 -0400
In-Reply-To: <1348698769-760-7-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 26 Sep 2012 15:32:49 -0700

> Hardware tx scheduling can cause some starvation of a tx ring with small
> packets if other tx rings have jumbo or TSO packets.  The default setting
> of 1 TX ring gives the best overall performance in many common traffic
> scenarios.  The user can change it using ethttol -L if desired.
> 
> Update version to 3.125.
> 
> Reviewed-by: Nithin Nayak Sujir <nsujir@broadcom.com>
> Reviewed-by: Benjamin Li <benli@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

This gets into an area I don't like.

Individual drivers making decisions about defaults that sound like
system wide ones.

What makes tg3 so special that only it should have this default
setting?

I also can't see how this "one guy spamming small packets while
another generates TSO frames" completely nullifies the SMP gains
from using multiple TX rings and distributing traffic.

I'm not applying this patch set.
