From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: 2.6.28-git1 build failure
Date: Sun, 28 Dec 2008 20:36:22 -0800
Message-ID: <495853C6.6030000@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sean.hefty@intel.com
To: Roland Dreier <rdreier@cisco.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:55782 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750748AbYL2Egb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Dec 2008 23:36:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

drivers/built-in.o: In function `addr_resolve_remote':
addr.c:(.text+0x12fe75): undefined reference to `ip6_route_output'
drivers/built-in.o: In function `rdma_translate_ip':
(.text+0x1301a7): undefined reference to `ipv6_chk_addr'
drivers/built-in.o: In function `rdma_resolve_ip':
(.text+0x1303a9): undefined reference to `ipv6_chk_addr'
drivers/built-in.o: In function `rdma_resolve_ip':
(.text+0x13051b): undefined reference to `ip6_route_output'

when CONFIG_IPV6=n.

-- 
~Randy
