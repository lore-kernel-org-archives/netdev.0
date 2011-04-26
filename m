From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH net-next-2.6 0/7] SCTP updates for net-next-2.6
Date: Tue, 26 Apr 2011 11:44:05 +0800
Message-ID: <4DB63F85.2090609@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	lksctp <linux-sctp@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:63469 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S932970Ab1DZDoT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Apr 2011 23:44:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David

Here is a set of SCTP patches for net-next-2.6, the last part
from vlad's lksctp-dev tree, update SCTP IPv6 routing and IPSec
issues. Please apply.

Vlad Yasevich (4):
      sctp: cache the ipv6 source after route lookup
      sctp: make sctp over IPv6 work with IPsec
      sctp: remove useless arguments from get_saddr() call
      sctp: clean up route lookup calls

Wei Yongjun (2):
      sctp: clean up IPv6 route and XFRM lookups
      sctp: fix IPv6 source address output routing with IPsec

Weixing Shi (1):
      sctp: fix sctp to work with ipv6 source address routing

 include/net/sctp/structs.h |   17 ++--
 net/sctp/ipv6.c            |  186 ++++++++++++++++++++++++++-----------------
 net/sctp/protocol.c        |   57 ++++++-------
 net/sctp/socket.c          |    2 +-
 net/sctp/transport.c       |   28 ++++---
 5 files changed, 162 insertions(+), 128 deletions(-)


