From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: skb_frag_t can be smaller on small
 arches
Date: Thu, 23 Sep 2010 12:05:16 -0700 (PDT)
Message-ID: <20100923.120516.123994233.davem@davemloft.net>
References: <1285254414.2509.50.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53948
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751844Ab0IWTE4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Sep 2010 15:04:56 -0400
In-Reply-To: <1285254414.2509.50.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 23 Sep 2010 17:06:54 +0200

> David
> 
> I remember you reacted on my three years old comment about
> commit a309bb072b96bfe (Page offsets and lengths need to be __u32.)
> 
> http://www.mail-archive.com/netdev@vger.kernel.org/msg43999.html
> 
> Could we reconsider the thing now and allow to shrink
> sizeof(skb_shared_info) from 0x104 to 0xbc, considering nothing happened
> about scatterlist work ?
> 
> This saves 128 bytes on i386 because of alignments, and can be reverted
> pretty fast if needed.

Yes, this seems reasonable.  I'll probably apply this, thanks!
