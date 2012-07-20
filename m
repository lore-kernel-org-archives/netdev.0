From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipv4: show pmtu in route list
Date: Sat, 21 Jul 2012 02:46:09 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1207210235440.2714@ja.ssi.bg>
References: <1342774928-29301-1-git-send-email-ja@ssi.bg> <20120720.111620.1609537308761180.davem@davemloft.net> <alpine.LFD.2.00.1207210219470.1893@ja.ssi.bg> <20120720.162215.2278959554536542562.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:44647 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751901Ab2GTXir (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jul 2012 19:38:47 -0400
In-Reply-To: <20120720.162215.2278959554536542562.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Fri, 20 Jul 2012, David Miller wrote:

> From: Julian Anastasov <ja@ssi.bg>
> Date: Sat, 21 Jul 2012 02:26:28 +0300 (EEST)
> 
> > 	I'll try this weekend to reorganize the seqlock
> > usage in tcp_metrics.c and to provide method to feed
> > rt_fill_info with values from this cache.
> 
> Wouldn't it be better to just export the TCP metrics via it's own
> file or netlink facility?
> 
> They keying of the TCP metrics is completely different from how routes
> are key'd.  So I see little value in creating the illusion that these
> two things live in the same keying domain.
> 
> The routing cache will be completely gone and /proc/net/rt_cache will
> be an empty file.

	OK, then I'll try it in this way. When I have some
plan I'll be back for comments before implementing it.

Regards

--
Julian Anastasov <ja@ssi.bg>
