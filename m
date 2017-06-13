From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] networking: use skb_put_zero()
Date: Tue, 13 Jun 2017 13:54:13 -0400 (EDT)
Message-ID: <20170613.135413.281023855002218492.davem@davemloft.net>
References: <20170613122818.3523-1-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, johannes.berg@intel.com
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46154 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753439AbdFMRyQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 13:54:16 -0400
In-Reply-To: <20170613122818.3523-1-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Tue, 13 Jun 2017 14:28:18 +0200

> From: Johannes Berg <johannes.berg@intel.com>
> 
> Use the recently introduced helper to replace the pattern of
> skb_put() && memset(), this transformation was done with the
> following spatch:
> 
> @@
> identifier p;
> expression len;
> expression skb;
> @@
> -p = skb_put(skb, len);
> -memset(p, 0, len);
> +p = skb_put_zero(skb, len);
> 
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>

Applied, thanks!
