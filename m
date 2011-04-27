From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH net-next-2.6 0/5 v2] SCTP updates for net-next-2.6
Date: Wed, 27 Apr 2011 15:35:25 +0800
Message-ID: <4DB7C73D.3000406@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	lksctp <linux-sctp@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:55335 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753463Ab1D0Hfp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Apr 2011 03:35:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David

Here is a set of SCTP patches for net-next-2.6, the last part
from vlad's lksctp-dev tree, update SCTP IPv6 routing and IPSec
issues. Please apply.

Changelog:
  - redo the intermediate builds test and function test.
  - remove useless ->dst_saddr member of sctp_pf
  - merge some fix for original patch

Vlad Yasevich (4):
      sctp: cache the ipv6 source after route lookup
      sctp: make sctp over IPv6 work with IPsec
      sctp: remove useless arguments from get_saddr() call
      sctp: clean up route lookup calls

Weixing Shi (1):
      sctp: fix sctp to work with ipv6 source address routing

 include/net/sctp/structs.h |   18 ++---
 net/sctp/ipv6.c            |  183 +++++++++++++++++++++++++------------------
 net/sctp/protocol.c        |   54 ++++++-------
 net/sctp/socket.c          |    2 +-
 net/sctp/transport.c       |   28 ++++---
 5 files changed, 153 insertions(+), 132 deletions(-)


