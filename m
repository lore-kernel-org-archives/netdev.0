From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] netfilter: xt_socket: use IP early demux
Date: Wed, 22 May 2013 14:27:33 -0700 (PDT)
Message-ID: <20130522.142733.458456664835859037.davem@davemloft.net>
References: <1369256466.3301.364.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, kaber@trash.net
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44566 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756096Ab3EVV1f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 17:27:35 -0400
In-Reply-To: <1369256466.3301.364.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 22 May 2013 14:01:06 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> With IP early demux added in linux-3.6, we perform TCP lookup in IP
> layer before iptables hooks.
> 
> We can avoid doing a second lookup in xt_socket.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Acked-by: David S. Miller <davem@davemloft.net>
