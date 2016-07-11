From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] tcp: make challenge acks less predictable
Date: Mon, 11 Jul 2016 13:34:00 -0700 (PDT)
Message-ID: <20160711.133400.1349480895641773377.davem@davemloft.net>
References: <CAPzkZjz1R_T8q75LXLBc91j7YrngxdPc-o2Hpz+4YYyoWLantA@mail.gmail.com>
	<1468052160.30694.51.camel@edumazet-glaptop3.roam.corp.google.com>
	<1468137842.30694.58.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ycao009@ucr.edu, netdev@vger.kernel.org, zhiyunq@cs.ucr.edu,
	torvalds@linux-foundation.org, ycheng@google.com,
	ncardwell@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60248 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751125AbcGKUeC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2016 16:34:02 -0400
In-Reply-To: <1468137842.30694.58.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 10 Jul 2016 10:04:02 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Yue Cao claims that current host rate limiting of challenge ACKS
> (RFC 5961) could leak enough information to allow a patient attacker
> to hijack TCP sessions. He will soon provide details in an academic
> paper.
> 
> This patch increases the default limit from 100 to 1000, and adds
> some randomization so that the attacker can no longer hijack
> sessions without spending a considerable amount of probes.
> 
> Based on initial analysis and patch from Linus.
> 
> Note that we also have per socket rate limiting, so it is tempting
> to remove the host limit in the future.
> 
> v2: randomize the count of challenge acks per second, not the period.
> 
> Fixes: 282f23c6ee34 ("tcp: implement RFC 5961 3.2")
> Reported-by: Yue Cao <ycao009@ucr.edu>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>

Applied and queued up for -stable, thanks Eric.
