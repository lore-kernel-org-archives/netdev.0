From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: fix the rcu race between free_fib_info and
 ip_route_output_slow
Date: Tue, 22 May 2012 23:49:20 -0400 (EDT)
Message-ID: <20120522.234920.1047532847473945281.davem@davemloft.net>
References: <1337742123.14538.175.camel@ymzhang.sh.intel.com>
	<20120522.232310.911242148705021745.davem@davemloft.net>
	<1337743841.14538.178.camel@ymzhang.sh.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kunx.jiang@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: yanmin_zhang@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54041 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758841Ab2EWDtZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 May 2012 23:49:25 -0400
In-Reply-To: <1337743841.14538.178.camel@ymzhang.sh.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yanmin Zhang <yanmin_zhang@linux.intel.com>
Date: Wed, 23 May 2012 11:30:41 +0800

> How about the new patch posted in the end of previous reply? It does move the
> the resetting to RCU release.
> https://lkml.org/lkml/2012/5/22/558?

If you test it and submit it formally I'll probably apply it.
