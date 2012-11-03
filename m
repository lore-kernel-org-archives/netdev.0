From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next v2] ipv6: introduce ip6_rt_put()
Date: Sat, 03 Nov 2012 15:00:29 -0400 (EDT)
Message-ID: <20121103.150029.221846251455461205.davem@davemloft.net>
References: <1351505599-21096-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57784 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753724Ab2KCTAb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Nov 2012 15:00:31 -0400
In-Reply-To: <1351505599-21096-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Mon, 29 Oct 2012 18:13:19 +0800

> V2:
> fix a typo
> more dst_release() -> ip6_rt_put()
> 
> As suggested by Eric, we could introduce a helper function
> for ipv6 too, to avoid checking if rt is NULL before
> dst_release().
> 
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Applied.
