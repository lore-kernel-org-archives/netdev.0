From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6-multicast: Fix memory leak in input path.
Date: Tue, 27 Sep 2011 15:16:16 -0400 (EDT)
Message-ID: <20110927.151616.1706187903528893128.davem@davemloft.net>
References: <1317149897-14932-1-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53133 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751825Ab1I0TQT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2011 15:16:19 -0400
In-Reply-To: <1317149897-14932-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: greearb@candelatech.com
Date: Tue, 27 Sep 2011 11:58:17 -0700

> From: Ben Greear <greearb@candelatech.com>
> 
> Have to free the skb before returning if we fail
> the fib lookup.
> 
> Signed-off-by: Ben Greear <greearb@candelatech.com>

Applied, thanks.
