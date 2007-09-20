From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH - net-2.6.24 0/2] Introduce and use print_ip and print_ipv6
Date: Fri, 21 Sep 2007 01:05:52 +0200
Message-ID: <20070920230552.GF15613@postel.suug.ch>
References: <1190271211.26101.91.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>,
	Andrew Morton <akpm@linux-foundation.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:57018 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750838AbXITXFc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Sep 2007 19:05:32 -0400
Content-Disposition: inline
In-Reply-To: <1190271211.26101.91.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Joe Perches <joe@perches.com> 2007-09-19 23:53
> In the same vein as print_mac, the implementations
> introduce declaration macros:
> 	DECLARE_IP_BUF(var)
> 	DECLARE_IPV6_BUF(var)
> and functions:
> 	print_ip
> 	print_ipv6
> 	print_ipv6_nofmt
> 
> IPV4 Use:
> 
> 	DECLARE_IP_BUF(ipbuf);
> 	__be32 addr;
> 	print_ip(ipbuf, addr);
> 
> IPV6 use:
> 
> 	DECLARE_IPV6_BUF(ipv6buf);
> 	const struct in6_addr *addr;
> 	print_ipv6(ipv6buf, addr);
> and
> 	print_ipv6_nofmt(ipv6buf, addr);
> 
> compiled x86, defconfig and allyesconfig

What exactly is the advantage of this?
