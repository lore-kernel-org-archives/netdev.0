From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 1/1] net: ethernet: davinci_cpdma: Add boundary for
 rx and tx descriptors
Date: Tue, 11 Dec 2012 11:07:19 -0800
Message-ID: <1355252839.27891.131.camel@edumazet-glaptop>
References: <20121211.133058.2238010228178961245.davem@davemloft.net>
	 <20121211.133426.484976995112519196.davem@davemloft.net>
	 <1355252096.27891.130.camel@edumazet-glaptop>
	 <20121211.135759.1010213285970148974.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org,
	s.hauer@pengutronix.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:39408 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753868Ab2LKTHX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2012 14:07:23 -0500
In-Reply-To: <20121211.135759.1010213285970148974.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-12-11 at 13:57 -0500, David Miller wrote:
> From: Eric Dumazet <erdnetdev@gmail.com>
> Date: Tue, 11 Dec 2012 10:54:56 -0800
> 
> > Suggested fix : add a TCQ_F_MQSLAVE flag to allow dequeue_skb() to test
> > the netif_xmit_frozen_or_stopped() status _before_ dequeing packet from
> > qdisc.
> 
> This sounds fine to me.
> --

By the way we also could set this 'flag' for non multi queue devices.
