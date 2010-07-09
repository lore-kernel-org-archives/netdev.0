From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tproxy: nf_tproxy_assign_sock() can handle tw sockets
Date: Fri, 09 Jul 2010 10:53:30 -0700 (PDT)
Message-ID: <20100709.105330.104045737.davem@davemloft.net>
References: <1278626921.2435.73.camel@edumazet-laptop>
	<AANLkTiliBClahTfb41M5BDi1etg5pgkqEz_VfGrn_mK4@mail.gmail.com>
	<1278695580.2696.55.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: felipewd@gmail.com, kaber@trash.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48284
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752749Ab0GIRxQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jul 2010 13:53:16 -0400
In-Reply-To: <1278695580.2696.55.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 09 Jul 2010 19:13:00 +0200

> Reviewing tproxy stuff I spotted a problem in nf_tproxy_assign_sock()
> but I could not see how it could explain your crash.
> 
> We can read uninitialized memory and trigger a fault in
> nf_tproxy_assign_sock(), not later in tcp_recvmsg()...
> 
> David, Patrick, what do you think ?
> 
> Thanks
> 
> [PATCH] tproxy: nf_tproxy_assign_sock() can handle tw sockets
> 
> transparent field of a socket is either inet_twsk(sk)->tw_transparent
> for timewait sockets, or inet_sk(sk)->transparent for other sockets
> (TCP/UDP).
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Looks fine to me:

Acked-by: David S. Miller <davem@davemloft.net>
