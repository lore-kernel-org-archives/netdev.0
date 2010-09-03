From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: remove two kmemcheck annotations
Date: Fri, 03 Sep 2010 09:45:04 -0700 (PDT)
Message-ID: <20100903.094504.57458838.davem@davemloft.net>
References: <1283531228.2453.1162.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44239
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755961Ab0ICQor (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Sep 2010 12:44:47 -0400
In-Reply-To: <1283531228.2453.1162.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 03 Sep 2010 18:27:08 +0200

> __alloc_skb() uses a memset() to clear all the beginning of skb,
> including bitfields contained in 'flags1' & 'flags2'.
> 
> We dont need any more to use kmemcheck_annotate_bitfield() on these
> fields. However, we still need it for the clone part, which is not
> cleared.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
