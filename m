From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 1/4] [IPv6] Add link and site-local scope inline
Date: Fri, 06 Apr 2007 16:00:30 +0900 (JST)
Message-ID: <20070406.160030.75539924.yoshfuji@linux-ipv6.org>
References: <4615BCA1.6000608@hp.com>
	<20070406.122433.60252840.yoshfuji@linux-ipv6.org>
	<4615EAC0.3080709@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, dccp@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net, yoshfuji@linux-ipv6.org
To: brian.haley@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:40580 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1767535AbXDFG7i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Apr 2007 02:59:38 -0400
In-Reply-To: <4615EAC0.3080709@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <4615EAC0.3080709@hp.com> (at Fri, 06 Apr 2007 02:37:52 -0400), Brian Haley <brian.haley@hp.com> says:

> static inline int ipv6_addr_scope_linklocal(const struct in6_addr *a)
> {
> return ((a->s6_addr32[0] & htonl(0xFFC00000)) == htonl(0xFE800000) ||
>          ((a->s6_addr32[0] & htonl(0xFF000000)) == htonl(0xFF000000) &&
>           ((a)->s6_addr[1] & 0x0f) == IPV6_ADDR_SCOPE_LINKLOCAL)))
> }
> 
> That's not that clean an inline anymore, but still doable...

I would prefer to have ipv6_addr_linklocal() and
ipv6_addr_mc_linklocal() aligning with RFC3493.

--yoshfuji
