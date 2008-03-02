From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [GIT PULL] [INET]: Updates for net-2.6.26.
Date: Mon, 03 Mar 2008 00:44:49 +0900 (JST)
Message-ID: <20080303.004449.98475557.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:53616 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753403AbYCBPnt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Mar 2008 10:43:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

Please consider pulling following changesets on top of net-2.6.26
tree from
        git://git.skbuff.net/gitroot/yoshfuji/linux-2.6-dev.git net-2.6.26-inet-20080302

I'm not including the diff itself in this mail because of
ugly renames, but I will do if requested, of course.

Regards,

---

HEADLINES
---------

    [TCP]: lower stack usage in cookie_hash() function
    [TCP]: Add IPv6 support to TCP SYN cookies
    [UDP]: Allow users to configure UDP-Lite.
    [IPV4]: Fix size description of CONFIG_INET.
    [IPV4] UDP: Move IPv4-specific bits to other file.
    [IPV6] UDP: Rename IPv6 UDP files.
    [IPV6]: Move packet_type{} related bits to af_inet6.c.
    [IPV6] SYSCTL: complete initialization for sysctl table in subsystem code.
    [IPV6]: Use htonl() instead of __constant_htonl() where appricable.
    [NET] NEIGHBOUR: Remove unused neigh_is_connected().
    [IPV6] ADDRLABEL: Sort ip6addrlbl_init_table{} by prefix length.
    [IPV6]: Make ndisc_flow_init() common for later use.
    [IPV6]: Make ndisc_dst_alloc() common for later use.
    [IPV6] MCAST: Use standard path for sending MLD/MLDv2 messages.

DIFFSTAT
--------

 include/linux/icmpv6.h     |    8 
 include/linux/udp.h        |   11 
 include/net/addrconf.h     |   16 -
 include/net/ip6_route.h    |    8 
 include/net/ipv6.h         |    9 
 include/net/neighbour.h    |    6 
 include/net/tcp.h          |    8 
 include/net/transp_v6.h    |    5 
 include/net/udplite.h      |    9 
 net/Kconfig                |    2 
 net/ipv4/Kconfig           |   10 
 net/ipv4/Makefile          |    3 
 net/ipv4/af_inet.c         |    7 
 net/ipv4/proc.c            |    5 
 net/ipv4/syncookies.c      |   11 
 net/ipv4/tcp_input.c       |    1 
 net/ipv4/tcp_minisocks.c   |    2 
 net/ipv4/tcp_output.c      |    1 
 net/ipv4/udp.c             | 1090 ------------------------------------------
 net/ipv4/udp_ipv4.c        | 1134 ++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/udplite.c         |  121 -----
 net/ipv4/udplite_ipv4.c    |  121 +++++
 net/ipv6/Makefile          |    4 
 net/ipv6/addrlabel.c       |   11 
 net/ipv6/af_inet6.c        |  137 +++++
 net/ipv6/icmp.c            |   20 +
 net/ipv6/ip6_fib.c         |    2 
 net/ipv6/ipv6_sockglue.c   |  128 -----
 net/ipv6/mcast.c           |   66 ++-
 net/ipv6/ndisc.c           |   25 -
 net/ipv6/proc.c            |    6 
 net/ipv6/route.c           |   41 +-
 net/ipv6/syncookies.c      |  267 ++++++++++
 net/ipv6/sysctl_net_ipv6.c |   15 -
 net/ipv6/tcp_ipv6.c        |   77 ++-
 net/ipv6/udp.c             | 1065 -----------------------------------------
 net/ipv6/udp_ipv6.c        | 1065 +++++++++++++++++++++++++++++++++++++++++
 net/ipv6/udplite.c         |  125 -----
 net/ipv6/udplite_ipv6.c    |  125 +++++
 39 files changed, 3115 insertions(+), 2652 deletions(-)

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
