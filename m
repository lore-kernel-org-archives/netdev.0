From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netfilter: TCP and raw fix for ip_route_me_harder
Date: Sun, 07 Aug 2011 22:53:52 -0700 (PDT)
Message-ID: <20110807.225352.1009726356333252181.davem@davemloft.net>
References: <alpine.LFD.2.00.1108072158050.1423@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48540 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752252Ab1HHFyA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2011 01:54:00 -0400
In-Reply-To: <alpine.LFD.2.00.1108072158050.1423@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Sun, 7 Aug 2011 22:11:00 +0300 (EEST)

> 
> 	TCP in some cases uses different global (raw) socket
> to send RST and ACK. The transparent flag is not set there.
> Currently, it is a problem for rerouting after the previous
> change.
> 
> 	Fix it by simplifying the checks in ip_route_me_harder
> and use FLOWI_FLAG_ANYSRC even for sockets. It looks safe
> because the initial routing allowed this source address to
> be used and now we just have to make sure the packet is rerouted.
> 
> 	As a side effect this also allows rerouting for normal
> raw sockets that use spoofed source addresses which was not possible
> even before we eliminated the ip_route_input call.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Applied.
