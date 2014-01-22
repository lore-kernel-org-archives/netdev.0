From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: protect protocols not handling ipv4 from v4
 connection/bind attempts
Date: Tue, 21 Jan 2014 16:59:41 -0800 (PST)
Message-ID: <20140121.165941.1593478240200500821.davem@davemloft.net>
References: <20140120041639.GA27055@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38755 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752677AbaAVA7l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 19:59:41 -0500
In-Reply-To: <20140120041639.GA27055@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Mon, 20 Jan 2014 05:16:39 +0100

> Some ipv6 protocols cannot handle ipv4 addresses, so we must not allow
> connecting and binding to them. sendmsg logic does already check msg->name
> for this but must trust already connected sockets which could be set up
> for connection to ipv4 address family.
> 
> Per-socket flag ipv6only is of no use here, as it is under users control
> by setsockopt.
> 
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied.  Is the plan to add support to at least ping?

Thanks.
