From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: fix more NULL deref after prequeue changes
Date: Tue, 09 Dec 2014 21:39:49 -0500 (EST)
Message-ID: <20141209.213949.588465548847992235.davem@davemloft.net>
References: <CALdTtnuazPdMNsOHzzersmyHvLjwxSq1BZoA5ZAdU-0QZtwUsg@mail.gmail.com>
	<1418145804.27198.0.camel@edumazet-glaptop2.roam.corp.google.com>
	<1418147768.27198.7.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dann.frazier@canonical.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41281 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751807AbaLJCjy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 21:39:54 -0500
In-Reply-To: <1418147768.27198.7.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 09 Dec 2014 09:56:08 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> When I cooked commit c3658e8d0f1 ("tcp: fix possible NULL dereference in
> tcp_vX_send_reset()") I missed other spots we could deref a NULL
> skb_dst(skb)
> 
> Again, if a socket is provided, we do not need skb_dst() to get a
> pointer to network namespace : sock_net(sk) is good enough.
> 
> Reported-by: Dann Frazier <dann.frazier@canonical.com>
> Bisected-by: Dann Frazier <dann.frazier@canonical.com>
> Tested-by: Dann Frazier <dann.frazier@canonical.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Fixes: ca777eff51f7 ("tcp: remove dst refcount false sharing for prequeue mode")

Applied and queued up for 3.18-stable.
