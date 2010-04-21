From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] fasync: RCU locking
Date: Wed, 21 Apr 2010 16:19:48 -0700 (PDT)
Message-ID: <20100421.161948.253502140.davem@davemloft.net>
References: <1271230961.16881.630.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33820
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755402Ab0DUXTn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 19:19:43 -0400
In-Reply-To: <1271230961.16881.630.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 14 Apr 2010 09:42:41 +0200

> [PATCH net-next-2.6] fasync: RCU locking
> 
> kill_fasync() uses a central rwlock, candidate for RCU conversion.
> 
> We can remove __kill_fasync() direct use in net, and rename it to
> kill_fasync_rcu()
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

This looks good to me, applied, thanks Eric.
