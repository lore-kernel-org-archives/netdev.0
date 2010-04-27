From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2x: add support for receive hashing
Date: Tue, 27 Apr 2010 10:20:38 -0700 (PDT)
Message-ID: <20100427.102038.57469310.davem@davemloft.net>
References: <4BD6E887.3000804@athenacr.com>
	<20100427.095108.68126984.davem@davemloft.net>
	<1272388439.2295.369.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bmb@athenacr.com, therbert@google.com, netdev@vger.kernel.org,
	rick.jones2@hp.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36294
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753461Ab0D0RUc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 13:20:32 -0400
In-Reply-To: <1272388439.2295.369.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 27 Apr 2010 19:13:59 +0200

> So we have a BIG problem :
> 
> All cpus are fighting to get the socket lock,
> and very litle progress is done.
> 
> Note this problem has nothing to do with RPS, we could have 
> it with multiqueue as well.
> 
> Oh well...

Indeed, a huge issue, in that we haven't converted the UDP hash over
to RCU yet :-)

But because of the transient bind nature of UDP there are still a bunch
of cases that won't even cure.
