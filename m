From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH - net-2.6.24 0/2] Introduce and use print_ip and
 print_ipv6
Date: Thu, 20 Sep 2007 07:55:32 -0700
Message-ID: <20070920075532.b20fad42.randy.dunlap@oracle.com>
References: <1190271211.26101.91.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>,
	Andrew Morton <akpm@linux-foundation.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:62484 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752344AbXITO5O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2007 10:57:14 -0400
In-Reply-To: <1190271211.26101.91.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 19 Sep 2007 23:53:31 -0700 Joe Perches wrote:

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


How large are the patches if you posted them for review instead
of just referencing gits for them?  (which cuts down on review
possibilities)

---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
