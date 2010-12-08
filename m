From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: call dev_queue_xmit_nit() after
 skb_dst_drop()
Date: Wed, 08 Dec 2010 10:38:01 -0800 (PST)
Message-ID: <20101208.103801.260090431.davem@davemloft.net>
References: <1291706359.2769.17.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41500
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753896Ab0LHShd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 13:37:33 -0500
In-Reply-To: <1291706359.2769.17.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 07 Dec 2010 08:19:19 +0100

> Avoid some atomic ops on dst refcount, calling dev_queue_xmit_nit()
> after skb_dst_drop() in dev_hard_start_xmit().
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thank you.
