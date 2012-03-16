From: David Miller <davem@davemloft.net>
Subject: Re: 3.3-rc snmp6 panic
Date: Fri, 16 Mar 2012 01:53:57 -0700 (PDT)
Message-ID: <20120316.015357.1184207404095280795.davem@davemloft.net>
References: <20120315052506.GA5974@redhat.com>
	<1331794575.2543.17.camel@edumazet-laptop>
	<1331795591.2543.22.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davej@redhat.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36302 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422635Ab2CPIyA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2012 04:54:00 -0400
In-Reply-To: <1331795591.2543.22.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 15 Mar 2012 00:13:11 -0700

> [PATCH] ipv6: fix icmp6_dst_alloc()
> 
> commit 87a115783 ( ipv6: Move xfrm_lookup() call down into
> icmp6_dst_alloc().) forgot to convert one error path, leading
> to crashes in mld_sendpack()
> 
> Many thanks to Dave Jones for providing a very complete bug report.
> 
> Reported-by: Dave Jones <davej@redhat.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied and queued up for -stable, thanks.
