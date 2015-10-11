From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: synack packets can be attached to
 request sockets
Date: Sun, 11 Oct 2015 05:05:19 -0700 (PDT)
Message-ID: <20151011.050519.490473183761516116.davem@davemloft.net>
References: <1444305715.27760.9.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul@paul-moore.com, sds@tycho.nsa.gov,
	eparis@parisplace.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56998 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751432AbbJKLt0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Oct 2015 07:49:26 -0400
In-Reply-To: <1444305715.27760.9.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 08 Oct 2015 05:01:55 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> selinux needs few changes to accommodate fact that SYNACK messages
> can be attached to a request socket, lacking sk_security pointer
> 
> (Only syncookies are still attached to a TCP_LISTEN socket)
> 
> Adds a new sk_listener() helper, and use it in selinux and sch_fq
> 
> Fixes: ca6fb0651883 ("tcp: attach SYNACK messages to request sockets instead of listener")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported by: kernel test robot <ying.huang@linux.intel.com>

Applied, thanks everyone.
