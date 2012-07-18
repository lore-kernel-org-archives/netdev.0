From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: fix inet6_csk_xmit()
Date: Wed, 18 Jul 2012 09:00:25 -0700 (PDT)
Message-ID: <20120718.090025.2178532259429406950.davem@davemloft.net>
References: <1342595099.2626.1774.camel@edumazet-glaptop>
	<1342596218.2626.1813.camel@edumazet-glaptop>
	<1342597084.2626.1851.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, ycheng@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35052 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753856Ab2GRQA0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 12:00:26 -0400
In-Reply-To: <1342597084.2626.1851.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 18 Jul 2012 09:38:04 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> We should provide to inet6_csk_route_socket a struct flowi6 pointer,
> so that net6_csk_xmit() works correctly instead of sending garbage.
> 
> Also add some consts 
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Yuchung Cheng <ycheng@google.com>

Thanks a lot for fixing this Eric.

Applied.
