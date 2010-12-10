From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] filter: use size of fetched data in
 __load_pointer()
Date: Thu, 09 Dec 2010 20:46:32 -0800 (PST)
Message-ID: <20101209.204632.39180440.davem@davemloft.net>
References: <1291796775.2883.21.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46488
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756109Ab0LJEqF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Dec 2010 23:46:05 -0500
In-Reply-To: <1291796775.2883.21.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 08 Dec 2010 09:26:15 +0100

> __load_pointer() checks data we fetch from skb is included in head
> portion, but assumes we fetch one byte, instead of up to four.
> 
> This wont crash because we have extra bytes (struct skb_shared_info)
> after head, but this can read uninitialized bytes.
> 
> Fix this using size of the data (1, 2, 4 bytes) in the test.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

I'll apply this, thanks Eric.
