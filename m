From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next 0/6] Use FIELD_SIZEOF().
Date: Thu, 10 Jan 2013 02:19:29 +0900
Message-ID: <50EDA6A1.6070409@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:60711 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932156Ab3AIRTa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2013 12:19:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use FIELD_SIZEOF() macro instead of dummy pointer to check size
of cb in struct sk_buff.

YOSHIFUJI Hideaki (6):
  ipv4: Use FIELD_SIZEOF() in inet_init().
  ipv6: Use FIELD_SIZEOF() in inet6_init().
  netlink: Use FIELD_SIZEOF() in netlink_proto_init().
  openvswitch: Use FIELD_SIZEOF() in dp_init().
  rxrpc: Use FIELD_SIZEOF() in af_rxrpc_init().
  unix: Use FIELD_SIZEOF() in af_unix_init().

 net/ipv4/af_inet.c         |    3 +--
 net/ipv6/af_inet6.c        |    3 +--
 net/netlink/af_netlink.c   |    3 +--
 net/openvswitch/datapath.c |    3 +--
 net/rxrpc/af_rxrpc.c       |    4 ++--
 net/unix/af_unix.c         |    3 +--
 6 files changed, 7 insertions(+), 12 deletions(-)

-- 
1.7.9.5
