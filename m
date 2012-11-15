From: kbuild test robot <fengguang.wu@intel.com>
Subject: [net-next:master 30/50] net/ipv6/ip6_tunnel.c:1571:33: sparse:
 incorrect type in assignment (different base types)
Date: Thu, 15 Nov 2012 12:53:27 +0800
Message-ID: <50a47547.LCw999aGW0MWrHAq%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:46402 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992535Ab2KOExn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Nov 2012 23:53:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   702ed3c1a9dfe4dfe112f13542d0c9d689f5008b
commit: 0b112457229d8a17198a02f3cca32922d2e374f1 [30/50] ip6tnl: add support of link creation via rtnl


sparse warnings:

+ net/ipv6/ip6_tunnel.c:1571:33: sparse: incorrect type in assignment (different base types)
net/ipv6/ip6_tunnel.c:1571:33:    expected restricted __be32 [usertype] flowinfo
net/ipv6/ip6_tunnel.c:1571:33:    got unsigned int

vim +1571 net/ipv6/ip6_tunnel.c

0b112457 Nicolas Dichtel 2012-11-14  1555  
0b112457 Nicolas Dichtel 2012-11-14  1556  	if (data[IFLA_IPTUN_LOCAL])
0b112457 Nicolas Dichtel 2012-11-14  1557  		nla_memcpy(&parms->laddr, data[IFLA_IPTUN_LOCAL],
0b112457 Nicolas Dichtel 2012-11-14  1558  			   sizeof(struct in6_addr));
0b112457 Nicolas Dichtel 2012-11-14  1559  
0b112457 Nicolas Dichtel 2012-11-14  1560  	if (data[IFLA_IPTUN_REMOTE])
0b112457 Nicolas Dichtel 2012-11-14  1561  		nla_memcpy(&parms->raddr, data[IFLA_IPTUN_REMOTE],
0b112457 Nicolas Dichtel 2012-11-14  1562  			   sizeof(struct in6_addr));
0b112457 Nicolas Dichtel 2012-11-14  1563  
0b112457 Nicolas Dichtel 2012-11-14  1564  	if (data[IFLA_IPTUN_TTL])
0b112457 Nicolas Dichtel 2012-11-14  1565  		parms->hop_limit = nla_get_u8(data[IFLA_IPTUN_TTL]);
0b112457 Nicolas Dichtel 2012-11-14  1566  
0b112457 Nicolas Dichtel 2012-11-14  1567  	if (data[IFLA_IPTUN_ENCAP_LIMIT])
0b112457 Nicolas Dichtel 2012-11-14  1568  		parms->encap_limit = nla_get_u8(data[IFLA_IPTUN_ENCAP_LIMIT]);
0b112457 Nicolas Dichtel 2012-11-14  1569  
0b112457 Nicolas Dichtel 2012-11-14  1570  	if (data[IFLA_IPTUN_FLOWINFO])
0b112457 Nicolas Dichtel 2012-11-14 @1571  		parms->flowinfo = nla_get_u32(data[IFLA_IPTUN_FLOWINFO]);
0b112457 Nicolas Dichtel 2012-11-14  1572  
0b112457 Nicolas Dichtel 2012-11-14  1573  	if (data[IFLA_IPTUN_FLAGS])
0b112457 Nicolas Dichtel 2012-11-14  1574  		parms->flags = nla_get_u32(data[IFLA_IPTUN_FLAGS]);
0b112457 Nicolas Dichtel 2012-11-14  1575  
0b112457 Nicolas Dichtel 2012-11-14  1576  	if (data[IFLA_IPTUN_PROTO])
0b112457 Nicolas Dichtel 2012-11-14  1577  		parms->proto = nla_get_u8(data[IFLA_IPTUN_PROTO]);
0b112457 Nicolas Dichtel 2012-11-14  1578  }
0b112457 Nicolas Dichtel 2012-11-14  1579  

---
0-DAY kernel build testing backend         Open Source Technology Center
Fengguang Wu, Yuanhan Liu                              Intel Corporation
