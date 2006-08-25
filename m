From: David Miller <davem@davemloft.net>
Subject: Re: [GIT PATCH] IPv6 Updates for net-2.6.19
Date: Fri, 25 Aug 2006 16:06:58 -0700 (PDT)
Message-ID: <20060825.160658.55726449.davem@davemloft.net>
References: <20060825.030034.68559899.yoshfuji@linux-ipv6.org>
	<44EF4F95.7030305@hp.com>
	<20060826.074438.22263593.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:2993
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964878AbWHYXGy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Aug 2006 19:06:54 -0400
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20060826.074438.22263593.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Sat, 26 Aug 2006 07:44:38 +0900 (JST)

> In article <44EF4F95.7030305@hp.com> (at Fri, 25 Aug 2006 15:29:25 -0400), Brian Haley <brian.haley@hp.com> says:
> 
> > >  				.saddr = iph->saddr,
> > > +				.fwmark = skb->nfmark,
> > >  				.flowlabel = (* (u32 *) iph)&IPV6_FLOWINFO_MASK,
> :
> > I can't build the latest 2.6.19-git with this patch, skb->nfmark 
> > requires CONFIG_NETFILTER, which isn't in my .config.  The obvious 
> > workaround is the patch below, but that might not be what you want.  Can 
> > send my .config if you need it.
> 
> Your fix is appropriate.
> 
> Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

It seems to make better sense to protect this with
IPV6_ROUTE_FWMARK instead of NETFILTER.  And it is
consistent with ipv4 side.

So that's how I will fix this build problem.

Thanks.
