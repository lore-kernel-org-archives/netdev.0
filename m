From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: ensure epoll edge trigger wakeup when out of
 memory
Date: Tue, 19 May 2015 00:09:45 -0400 (EDT)
Message-ID: <20150519.000945.697478668443801629.davem@davemloft.net>
References: <20150515211707.D9FC480066@prod-mail-relay07.akamai.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org, ncardwell@google.com,
	ycheng@google.com
To: jbaron@akamai.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34973 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750722AbbESEJr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 00:09:47 -0400
In-Reply-To: <20150515211707.D9FC480066@prod-mail-relay07.akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jason Baron <jbaron@akamai.com>
Date: Fri, 15 May 2015 21:17:07 +0000 (GMT)

> From: Jason Baron <jbaron@akamai.com>
> 
> If we really can't get an skb allocated, make sure that we let
> userspace know. This at least gives us a chance to re-try or abort.
> 
> Signed-off-by: Jason Baron <jbaron@akamai.com>

Applied to net-next, thanks Jason.

Eric asked if we should perhaps return -ENOMEM here, and I'm not so
sure that's a good idea.  It is in a way a temporary failure that
should be retried.
