From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipv4: show pmtu in route list
Date: Sat, 21 Jul 2012 02:26:28 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1207210219470.1893@ja.ssi.bg>
References: <1342774928-29301-1-git-send-email-ja@ssi.bg> <20120720.111620.1609537308761180.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:44633 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752178Ab2GTXTK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jul 2012 19:19:10 -0400
In-Reply-To: <20120720.111620.1609537308761180.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Fri, 20 Jul 2012, David Miller wrote:

> From: Julian Anastasov <ja@ssi.bg>
> Date: Fri, 20 Jul 2012 12:02:08 +0300
> 
> > Is this patch still useful if routing cache is removed?
> 
> It is, since this function still gets used for rtnetlink route
> queries.  So I'll apply this, thanks Julian!
> 
> Which reminds me that we don't have way to inspect the new TCP metrics
> cache.  Would someone like to work on that?

	I'll try this weekend to reorganize the seqlock
usage in tcp_metrics.c and to provide method to feed
rt_fill_info with values from this cache.

Regards

--
Julian Anastasov <ja@ssi.bg>
