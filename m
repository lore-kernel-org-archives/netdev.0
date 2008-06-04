From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [GIT PULL] IPv6 Fixes (Take 3)
Date: Thu, 05 Jun 2008 04:07:44 +0900 (JST)
Message-ID: <20080605.040744.40936723.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:58114 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757302AbYFDTHH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2008 15:07:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

I've fixed up coding style and the reference to another commit
in commit log.

Please consider pulling following changes on top of net-2.6
(commit 7dccf1f4e1696c79bff064c3770867cc53cbc71c
("ax25: Fix NULL pointer dereference and lockup.").

git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-fix.git net-2.6-misc-20080605a

HEADLINES
---------

    [SCTP]: Fix NULL dereference of asoc.
    [IPV6] UDP: Possible dst leak in udpv6_sendmsg.
    [IPV6] ADDRCONF: Check range of prefix length
    [IPV6] TUNNEL6: Fix incoming packet length check for inter-protocol tunnel.
    [IPV4] TUNNEL4: Fix incoming packet length check for inter-protocol tunnel.
    [IPV6] ADDRCONF: Allow longer lifetime on 64bit archs.
    [IPV6]: Fix the return value of get destination options with NULL data pointer
    [IPV6]: Fix the data length of get destination options with short length
    [IPV6]: Check outgoing interface even if source address is unspecified.
    [IPV6] NETNS: Handle ancillary data in appropriate namespace.
    [IPV6]: Do not change protocol for raw IPv6 sockets.
    [IPV6]: inet_sk(sk)->cork.opt leak
    [IPV6]: Do not change protocol for UDPv6 sockets with pending sent data.

DIFFSTAT
--------

 include/net/addrconf.h     |   22 +++++++++
 include/net/sctp/structs.h |    3 +
 include/net/transp_v6.h    |    3 +
 include/net/udp.h          |    1 
 net/ipv4/tunnel4.c         |    2 -
 net/ipv4/udp.c             |    3 +
 net/ipv6/addrconf.c        |  107 ++++++++++++++++++++++++--------------------
 net/ipv6/datagram.c        |   45 ++++++++++---------
 net/ipv6/ip6_flowlabel.c   |    2 -
 net/ipv6/ipv6_sockglue.c   |   21 +++++++--
 net/ipv6/raw.c             |    2 -
 net/ipv6/route.c           |   12 +----
 net/ipv6/tunnel6.c         |    2 -
 net/ipv6/udp.c             |    8 ++-
 net/sctp/ipv6.c            |    5 +-
 net/sctp/protocol.c        |    3 +
 net/sctp/transport.c       |    2 -
 17 files changed, 146 insertions(+), 97 deletions(-)

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
