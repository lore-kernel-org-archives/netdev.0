From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] etherdevice: introduce eth_broadcast_addr
Date: Tue, 10 Jul 2012 18:07:13 -0700 (PDT)
Message-ID: <20120710.180713.2086889114899353418.davem@davemloft.net>
References: <1341310587.5131.2.camel@jlt3.sipsolutions.net>
	<20120708.235808.1602900783296556684.davem@davemloft.net>
	<1341937124.4475.27.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42623 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752338Ab2GKBHO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 21:07:14 -0400
In-Reply-To: <1341937124.4475.27.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Tue, 10 Jul 2012 18:18:44 +0200

> From: Johannes Berg <johannes.berg@intel.com>
> 
> A lot of code has either the memset or an inefficient copy
> from a static array that contains the all-ones broadcast
> address. Introduce eth_broadcast_addr() to fill an address
> with all ones, making the code clearer and allowing us to
> get rid of some constant arrays.
> 
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>

Applied, thanks.
