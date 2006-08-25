From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [GIT PATCH] IPv6 Updates for net-2.6.19
Date: Sat, 26 Aug 2006 07:44:38 +0900 (JST)
Message-ID: <20060826.074438.22263593.yoshfuji@linux-ipv6.org>
References: <20060825.030034.68559899.yoshfuji@linux-ipv6.org>
	<44EF4F95.7030305@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:59146 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S1751534AbWHYWmu
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Aug 2006 18:42:50 -0400
To: brian.haley@hp.com
In-Reply-To: <44EF4F95.7030305@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <44EF4F95.7030305@hp.com> (at Fri, 25 Aug 2006 15:29:25 -0400), Brian Haley <brian.haley@hp.com> says:

> >  				.saddr = iph->saddr,
> > +				.fwmark = skb->nfmark,
> >  				.flowlabel = (* (u32 *) iph)&IPV6_FLOWINFO_MASK,
:
> I can't build the latest 2.6.19-git with this patch, skb->nfmark 
> requires CONFIG_NETFILTER, which isn't in my .config.  The obvious 
> workaround is the patch below, but that might not be what you want.  Can 
> send my .config if you need it.

Your fix is appropriate.

Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

--yoshfuji
