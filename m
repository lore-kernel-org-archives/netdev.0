From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: inet_add_protocol() can use cmpxchg()
Date: Wed, 08 Sep 2010 21:31:43 -0700 (PDT)
Message-ID: <20100908.213143.241436777.davem@davemloft.net>
References: <1283986576.2428.21.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55345
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751003Ab0IIEbZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Sep 2010 00:31:25 -0400
In-Reply-To: <1283986576.2428.21.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 09 Sep 2010 00:56:16 +0200

> Use cmpxchg() to get rid of spinlocks in inet_add_protocol() and
> friends.
> 
> inet_protos[] & inet6_protos[] are moved to read_mostly section
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
