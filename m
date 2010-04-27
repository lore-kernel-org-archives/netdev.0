From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] rps: inet_rps_save_rxhash() argument is
 not const
Date: Tue, 27 Apr 2010 12:56:53 -0700 (PDT)
Message-ID: <20100427.125653.235688835.davem@davemloft.net>
References: <1272372171.2295.68.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49611
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756799Ab0D0T4r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 15:56:47 -0400
In-Reply-To: <1272372171.2295.68.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 27 Apr 2010 14:42:51 +0200

> const qualifier on sock argument is misleading, since we can modify rxhash.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.

It's a shame that because of the cast the compiler can't see this.
Instead it would be nice if the compiler only allowed casts from
a const pointer to another const pointer.
