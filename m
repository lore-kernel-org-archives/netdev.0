From: David Miller <davem@davemloft.net>
Subject: Re: 3.6 routing cache regression, multicast loopback broken
Date: Wed, 21 Nov 2012 12:25:46 -0500 (EST)
Message-ID: <20121121.122546.2071233763408394785.davem@davemloft.net>
References: <1352133471.12029.43.camel@sakura.staff.proxad.net>
	<alpine.LFD.2.00.1211210055040.1751@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mbizon@freebox.fr, netdev@vger.kernel.org
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53712 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754470Ab2KURZs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2012 12:25:48 -0500
In-Reply-To: <alpine.LFD.2.00.1211210055040.1751@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Wed, 21 Nov 2012 02:35:34 +0200 (EET)

> [PATCH net-next] ipv4: do not cache looped multicasts
> 
> 	We have two cases for outgoing multicasts
> depending on the membership: with or without RTCF_LOCAL.
> Currently, we use caching only if route to 224/4 is used.
> As we can not cache for both cases, optimize the caching
> for senders only, do not cache routes with RTCF_LOCAL
> flag set.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

The sad part is that you warned me about this issue nearly
2 years ago Julian, sorry :-/
