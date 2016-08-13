From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ipv6: suppress sparse warnings in IP6_ECN_set_ce()
Date: Sat, 13 Aug 2016 15:08:19 -0700 (PDT)
Message-ID: <20160813.150819.2051748557355400764.davem@davemloft.net>
References: <1470980901-26786-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com,
	johannes.berg@intel.com
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35533 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751229AbcHNInX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Aug 2016 04:43:23 -0400
In-Reply-To: <1470980901-26786-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Fri, 12 Aug 2016 07:48:21 +0200

> From: Johannes Berg <johannes.berg@intel.com>
> 
> Pass the correct type __wsum to csum_sub() and csum_add(). This doesn't
> really change anything since __wsum really *is* __be32, but removes the
> address space warnings from sparse.
> 
> Cc: Eric Dumazet <edumazet@google.com>
> Fixes: 34ae6a1aa054 ("ipv6: update skb->csum when CE mark is propagated")
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>

Applied, thanks.
