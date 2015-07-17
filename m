From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2] rhashtable: Allow other tasks to be
 scheduled in large lookup loops
Date: Fri, 17 Jul 2015 21:47:00 +0200
Message-ID: <1437162420.1026.25.camel@edumazet-glaptop2.roam.corp.google.com>
References: <25527e380ed6701a3c73185e28f547d6e1d5907f.1437123031.git.tgraf@suug.ch>
	 <alpine.LRH.2.11.1507172204220.13702@math.ut.ee>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, davem@davemloft.net,
	netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: mroos@linux.ee
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:33574 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751901AbbGQTrG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2015 15:47:06 -0400
Received: by wgmn9 with SMTP id n9so89657779wgm.0
        for <netdev@vger.kernel.org>; Fri, 17 Jul 2015 12:47:04 -0700 (PDT)
In-Reply-To: <alpine.LRH.2.11.1507172204220.13702@math.ut.ee>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-07-17 at 22:07 +0300, mroos@linux.ee wrote:
> > Depending on system speed, the large lookup/insert/delete loops of the testsuite can
> > take a considerable amount of time to complete causing watchdog warnings to appear.
> > Allow other tasks to be scheduled throughout the loops.
> > 
> > Reported-by: Meelis Roos <mroos@linux.ee>
> > Signed-off-by: Thomas Graf <tgraf@suug.ch>
> > ---
> > v2: Use cond_resched() instead schedule()
> 
> Tested it. The warning is gone from rhashtable test but now it is 
> present in rbtree test (it was not there before). Same kernel, just your 
> patch applied - but it should not change rbtree test???

Why not ?

rbtree tests need same kind of patches.
