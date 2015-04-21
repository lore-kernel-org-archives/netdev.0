From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: add memory barriers to write space paths
Date: Tue, 21 Apr 2015 15:58:15 -0400 (EDT)
Message-ID: <20150421.155815.1818097515812833010.davem@davemloft.net>
References: <20150420200507.21414203F@prod-mail-relay06.akamai.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: jbaron@akamai.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55292 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932096AbbDUT6U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2015 15:58:20 -0400
In-Reply-To: <20150420200507.21414203F@prod-mail-relay06.akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jason Baron <jbaron@akamai.com>
Date: Mon, 20 Apr 2015 20:05:07 +0000 (GMT)

> Ensure that we either see that the buffer has write space
> in tcp_poll() or that we perform a wakeup from the input
> side. Did not run into any actual problem here, but thought
> that we should make things explicit.
> 
> Signed-off-by: Jason Baron <jbaron@akamai.com>

This looks fine, applied, thanks.
