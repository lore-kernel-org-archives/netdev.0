From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] pch_gbe: fix bogus trylock conversion
Date: Tue, 26 Apr 2016 17:42:50 -0400 (EDT)
Message-ID: <20160426.174250.1298288123769064536.davem@davemloft.net>
References: <1461705270-29849-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42572 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751920AbcDZVmw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 17:42:52 -0400
In-Reply-To: <1461705270-29849-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Tue, 26 Apr 2016 23:14:30 +0200

> Should have converted 'if (trylock)' to 'lock'.
> 
> Fixes: a6086a893718db ("drivers: net: remove NETDEV_TX_LOCKED")
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
>  I re-checked the series and this was the only place where I messed up.

Applied.
