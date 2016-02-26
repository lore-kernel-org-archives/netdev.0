From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: Facility to report route quality of
 connected sockets
Date: Thu, 25 Feb 2016 22:01:40 -0500 (EST)
Message-ID: <20160225.220140.1022665279243146846.davem@davemloft.net>
References: <1456336972-3024417-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49171 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750767AbcBZDBm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 22:01:42 -0500
In-Reply-To: <1456336972-3024417-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Wed, 24 Feb 2016 10:02:52 -0800

> This patch add the SO_CNX_ADVICE socket option (setsockopt only). The
> purpose is to allow an application to give feedback to the kernel about
> the quality of the network path for a connected socket. The value
> argument indicates the type of quality report. For this initial patch
> the only supported advice is a value of 1 which indicates "bad path,
> please reroute"-- the action taken by the kernel is to call
> dst_negative_advice which will attempt to choose a different ECMP route,
> reset the TX hash for flow label and UDP source port in encapsulation,
> etc.
> 
> This facility should be useful for connected UDP sockets where only the
> application can provide any feedback about path quality. It could also
> be useful for TCP applications that have additional knowledge about the
> path outside of the normal TCP control loop.
> 
> Signed-off-by: Tom Herbert <tom@herbertland.com>

This looks fine, applied, thanks Tom.
