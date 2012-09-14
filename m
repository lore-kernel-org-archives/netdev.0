From: Dave Jones <davej@redhat.com>
Subject: Re: kernel BUG at kernel/timer.c:748!
Date: Fri, 14 Sep 2012 17:29:58 -0400
Message-ID: <20120914212958.GA25053@redhat.com>
References: <20120905043523.GA12988@redhat.com>
 <alpine.LFD.2.00.1209052343110.2201@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33515 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756132Ab2INVaN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Sep 2012 17:30:13 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1209052343110.2201@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 05, 2012 at 11:48:29PM +0300, Julian Anastasov wrote:
 
 > > kernel BUG at kernel/timer.c:748!
 > > Call Trace:
 > >  ? lock_sock_nested+0x8d/0xa0
 > >  sk_reset_timer+0x1c/0x30
 > >  ? sock_setsockopt+0x8c/0x960
 > >  inet_csk_reset_keepalive_timer+0x20/0x30
 > >  tcp_set_keepalive+0x3d/0x50
 > >  sock_setsockopt+0x923/0x960
 > >  ? trace_hardirqs_on_caller+0x16/0x1e0
 > >  ? fget_light+0x24c/0x520
 > >  sys_setsockopt+0xc6/0xe0
 > >  system_call_fastpath+0x1a/0x1f
 > 
 > 	Can this help? In case you see ICMPV6_PKT_TOOBIG...
 > 
 > [PATCH] tcp: fix possible socket refcount problem for ipv6

I just managed to reproduce this bug on rc5 with this patch,
so it doesn't seem to help.

	Dave
