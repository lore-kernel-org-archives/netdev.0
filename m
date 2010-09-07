From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: pskb_expand_head() optimization
Date: Mon, 06 Sep 2010 22:05:28 -0700 (PDT)
Message-ID: <20100906.220528.220056882.davem@davemloft.net>
References: <20100903.064633.27806839.davem@davemloft.net>
	<20100906.192003.232914158.davem@davemloft.net>
	<1283835729.2585.499.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36075
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751161Ab0IGFFK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Sep 2010 01:05:10 -0400
In-Reply-To: <1283835729.2585.499.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 07 Sep 2010 07:02:09 +0200

> I understand what you want to do, but problem is we need to perform a
> CAS2 operation : atomically changes two values (dataref and frag_list)

Ok, thanks for the review, I'll think some more about this.
