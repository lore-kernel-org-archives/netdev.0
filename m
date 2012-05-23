From: Yanmin Zhang <yanmin_zhang@linux.intel.com>
Subject: Re: [PATCH] ipv4: fix the rcu race between free_fib_info and
 ip_route_output_slow
Date: Wed, 23 May 2012 12:41:09 +0800
Message-ID: <1337748069.14538.181.camel@ymzhang.sh.intel.com>
References: <1337742123.14538.175.camel@ymzhang.sh.intel.com>
	 <20120522.232310.911242148705021745.davem@davemloft.net>
	 <1337743841.14538.178.camel@ymzhang.sh.intel.com>
	 <20120522.234920.1047532847473945281.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: kunx.jiang@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:35824 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751233Ab2EWEkS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 May 2012 00:40:18 -0400
In-Reply-To: <20120522.234920.1047532847473945281.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-05-22 at 23:49 -0400, David Miller wrote:
> From: Yanmin Zhang <yanmin_zhang@linux.intel.com>
> Date: Wed, 23 May 2012 11:30:41 +0800
> 
> > How about the new patch posted in the end of previous reply? It does move the
> > the resetting to RCU release.
> > https://lkml.org/lkml/2012/5/22/558?
> 
> If you test it and submit it formally I'll probably apply it.
We did test it. But it's hard to reproduce it. We hit it the issue
for a couple of times when running MTBF testing on Android smart phone.
Mostly, it happens after MTBF runs for more than 12 hours. To releasing
the product, MTBF testing should run for hundreds of hours. This bug
blocks it.

We would submit it formally and also run more testing.

Sorry for taking you too much time.
