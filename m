From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: make sure RTO_ONLINK is saved in routing cache
Date: Sat, 03 Dec 2011 01:32:53 -0500 (EST)
Message-ID: <20111203.013253.1033496549173534010.davem@davemloft.net>
References: <1322861982-3780-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53119 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750909Ab1LCGdI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2011 01:33:08 -0500
In-Reply-To: <1322861982-3780-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Fri,  2 Dec 2011 23:39:42 +0200

> 	__mkroute_output fails to work with the original tos
> and uses value with stripped RTO_ONLINK bit. Make sure we put
> the original TOS bits into rt_key_tos because it used to match
> cached route.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Applied, thanks a lot Julian.
