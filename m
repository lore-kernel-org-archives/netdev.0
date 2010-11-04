From: David Miller <davem@davemloft.net>
Subject: Re: Linux 2.6.37-rc1 (net/sched: cls_cgroup)
Date: Wed, 03 Nov 2010 18:56:11 -0700 (PDT)
Message-ID: <20101103.185611.115918611.davem@davemloft.net>
References: <20101103142156.73c2d3c9.randy.dunlap@oracle.com>
	<1288821677.2718.27.camel@edumazet-laptop>
	<20101103233105.GA26124@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, randy.dunlap@oracle.com,
	torvalds@linux-foundation.org, hadi@cyberus.ca, tgraf@suug.ch,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	bblum@andrew.cmu.edu
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36994
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754411Ab0KDBzr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Nov 2010 21:55:47 -0400
In-Reply-To: <20101103233105.GA26124@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 3 Nov 2010 18:31:05 -0500

> cls_cgroup: Fix crash on module unload
> 
> Somewhere along the lines net_cls_subsys_id became a macro when
> cls_cgroup is built as a module.  Not only did it make cls_cgroup
> completely useless, it also causes it to crash on module unload.
> 
> This patch fixes this by removing that macro.
> 
> Thanks to Eric Dumazet for diagnosing this problem.
> 
> Reported-by: Randy Dunlap <randy.dunlap@oracle.com>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, and queued up for -stable, thanks everyone!
