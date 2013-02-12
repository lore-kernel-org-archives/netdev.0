From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix infinite loop in __skb_recv_datagram()
Date: Tue, 12 Feb 2013 16:07:33 -0500 (EST)
Message-ID: <20130212.160733.2235089567079483883.davem@davemloft.net>
References: <1360638903.20362.32.camel@edumazet-glaptop>
	<CA+ydwtoBttwiVz+oy0hnetUTQMi7XHyS9bfGzjuP1L41srBk=g@mail.gmail.com>
	<1360685813.13993.12.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tt.rantala@gmail.com, netdev@vger.kernel.org, davej@redhat.com,
	xemul@parallels.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56894 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753195Ab3BLVHf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 16:07:35 -0500
In-Reply-To: <1360685813.13993.12.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 12 Feb 2013 08:16:53 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Tommi was fuzzing with trinity and reported the following problem :
> 
> commit 3f518bf745 (datagram: Add offset argument to __skb_recv_datagram)
> missed that a raw socket receive queue can contain skbs with no payload.
> 
> We can loop in __skb_recv_datagram() with MSG_PEEK mode, because
> wait_for_packet() is not prepared to skip these skbs.
 ...
> Reported-by: Tommi Rantala <tt.rantala@gmail.com>
> Tested-by: Tommi Rantala <tt.rantala@gmail.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
