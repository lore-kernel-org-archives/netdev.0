From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: use dst with ref during bcast/mcast loopback
Date: Sun, 07 Aug 2011 22:54:10 -0700 (PDT)
Message-ID: <20110807.225410.1273817575106297373.davem@davemloft.net>
References: <alpine.LFD.2.00.1108072232170.13644@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48553 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752443Ab1HHFyR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2011 01:54:17 -0400
In-Reply-To: <alpine.LFD.2.00.1108072232170.13644@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Sun, 7 Aug 2011 23:17:22 +0300 (EEST)

> 
> 	Make sure skb dst has reference when moving to
> another context. Currently, I don't see protocols that can
> hit it when sending broadcasts/multicasts to loopback using
> noref dsts, so it is just a precaution.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---
> 
> 	Please, review and apply if needed...

Better safe than sorry, applied, thanks!
