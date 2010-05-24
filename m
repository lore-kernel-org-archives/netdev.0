From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net_sched: Fix qdisc_notify()
Date: Sun, 23 May 2010 23:11:52 -0700 (PDT)
Message-ID: <20100523.231152.116127631.davem@davemloft.net>
References: <4BF7A929.2090007@trash.net>
	<1274531509.12793.7.camel@bigi>
	<1274596664.5020.40.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, kaber@trash.net, blp@nicira.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51807
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753089Ab0EXGLm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 May 2010 02:11:42 -0400
In-Reply-To: <1274596664.5020.40.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 23 May 2010 08:37:44 +0200

> [PATCH] net_sched: Fix qdisc_notify()
> 
> Ben Pfaff reported a kernel oops and provided a test program to
> reproduce it.
> 
> https://kerneltrap.org/mailarchive/linux-netdev/2010/5/21/6277805
> 
> tc_fill_qdisc() should not be called for builtin qdisc, or it
> dereference a NULL pointer to get device ifindex.
> 
> Fix is to always use tc_qdisc_dump_ignore() before calling
> tc_fill_qdisc().
> 
> Reported-by: Ben Pfaff <blp@nicira.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied and queued up for -stable.
