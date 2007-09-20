From: Joe Perches <joe@perches.com>
Subject: [PATCH - net-2.6.24 0/2] Introduce and use print_ip and print_ipv6
Date: Wed, 19 Sep 2007 23:53:31 -0700
Message-ID: <1190271211.26101.91.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>,
	Andrew Morton <akpm@linux-foundation.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:2599 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751167AbXITGxe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Sep 2007 02:53:34 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In the same vein as print_mac, the implementations
introduce declaration macros:
	DECLARE_IP_BUF(var)
	DECLARE_IPV6_BUF(var)
and functions:
	print_ip
	print_ipv6
	print_ipv6_nofmt

IPV4 Use:

	DECLARE_IP_BUF(ipbuf);
	__be32 addr;
	print_ip(ipbuf, addr);

IPV6 use:

	DECLARE_IPV6_BUF(ipv6buf);
	const struct in6_addr *addr;
	print_ipv6(ipv6buf, addr);
and
	print_ipv6_nofmt(ipv6buf, addr);

compiled x86, defconfig and allyesconfig

