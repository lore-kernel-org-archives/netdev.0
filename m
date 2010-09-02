From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] drivers/net : avoid some skb->ip_summed
 initializations
Date: Thu, 02 Sep 2010 12:38:01 -0700 (PDT)
Message-ID: <20100902.123801.102553189.davem@davemloft.net>
References: <1283444746.2454.1132.camel@edumazet-laptop>
	<20100902.094135.112603353.davem@davemloft.net>
	<1283454780.3699.22.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40946
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751217Ab0IBTho (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 15:37:44 -0400
In-Reply-To: <1283454780.3699.22.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 02 Sep 2010 21:13:00 +0200

> Well, I wanted to keep the CHECKSUM_NONE "as is" to ease grep games.

I understand but it's just too ugly to live, I think.

> Choices are :
> 
> 1) put it in lower case : skb_checksum_none_assert()
> 2) Use a macro instead.
> 3) Other idea ?

Respin with #1 please, thanks.
