From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [GIT PATCH] IPv6 Updates for net-2.6.19
Date: Sat, 26 Aug 2006 08:11:45 +0900 (JST)
Message-ID: <20060826.081145.35951258.yoshfuji@linux-ipv6.org>
References: <44EF4F95.7030305@hp.com>
	<20060826.074438.22263593.yoshfuji@linux-ipv6.org>
	<20060825.160658.55726449.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:60938 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S964808AbWHYXJ6
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Aug 2006 19:09:58 -0400
To: davem@davemloft.net
In-Reply-To: <20060825.160658.55726449.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20060825.160658.55726449.davem@davemloft.net> (at Fri, 25 Aug 2006 16:06:58 -0700 (PDT)), David Miller <davem@davemloft.net> says:

> > > > +				.fwmark = skb->nfmark,
:
> It seems to make better sense to protect this with
> IPV6_ROUTE_FWMARK instead of NETFILTER.  And it is
> consistent with ipv4 side.
> 
> So that's how I will fix this build problem.

Agreed.

--yoshfuji
