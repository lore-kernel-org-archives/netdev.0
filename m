From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: unset IFF_XMIT_DST_RELEASE in
 ipip_tunnel_setup()
Date: Fri, 29 May 2009 01:47:01 -0700 (PDT)
Message-ID: <20090529.014701.58473123.davem@davemloft.net>
References: <4A1EF7AE.2040404@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56175
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758464AbZE2IrB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 04:47:01 -0400
In-Reply-To: <4A1EF7AE.2040404@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 28 May 2009 22:44:30 +0200

> ipip_tunnel_xmit() might need skb->dst, so tell dev_hard_start_xmit()
> to no release it.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
