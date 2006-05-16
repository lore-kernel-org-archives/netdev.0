From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] tcpdump may trace some outbound packets twice.
Date: Tue, 16 May 2006 03:22:21 +0200
Message-ID: <4469294D.6010509@trash.net>
References: <E1FfnZP-0003St-00@gondolin.me.apana.org.au> <44692847.4080100@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, shemminger@osdl.org,
	ranjitm@google.com, akpm@osdl.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55272 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1750988AbWEPBWX
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 May 2006 21:22:23 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <44692847.4080100@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> 3) Clone the skb and have dev_queue_xmit_nit() consume it.
> 
> That should actually be pretty easy.

On second thought, thats not so great either. netdev_nit
just globally signals that there are some taps, but we
don't know if they're interested in a specific packet.

