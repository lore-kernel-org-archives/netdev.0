From: Michio Honda <micchie@sfc.wide.ad.jp>
Subject: [PATCH 0/6 v9] sctp: Auto-ASCONF patch series
Date: Thu, 2 Jun 2011 12:00:49 +0900
Message-ID: <4C8C57AE-E872-46F5-806D-DD2699F424C6@sfc.wide.ad.jp>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shonan.sfc.wide.ad.jp ([203.178.142.130]:49901 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759290Ab1FBDAv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2011 23:00:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From 907306fafe1ebdde2ad42aefbc6e45821b448cbf Mon Sep 17 00:00:00 2001
From: Michio Honda <micchie@sfc.wide.ad.jp>
Date: Thu, 2 Jun 2011 11:34:27 +0900
Subject: [PATCH 0/6 v9] sctp: Auto-ASCONF patch series

Series of 6 patches to support auto_asconf and the other related functionalities that auto_asconf relies on

Michio Honda (5):
  sctp: Add ADD/DEL ASCONF handling at the receiver.
  sctp: Add Auto-ASCONF support (core).
  sctp: Add sysctl support for Auto-ASCONF.
  sctp: Add socket option operation for Auto-ASCONF.
  sctp: Add ASCONF operation on the single-homed host

YOSHIFUJI Hideaki (1):
  sctp: Allow regular C expression in 4th argument for
    SCTP_DEBUG_PRINTK_IPADDR macro.

 include/net/sctp/sctp.h    |   11 ++-
 include/net/sctp/structs.h |   17 +++++
 include/net/sctp/user.h    |    1 +
 net/sctp/associola.c       |    6 ++
 net/sctp/bind_addr.c       |   15 ++++
 net/sctp/ipv6.c            |    2 +
 net/sctp/outqueue.c        |   13 ++++
 net/sctp/protocol.c        |  151 ++++++++++++++++++++++++++++++++++++++-
 net/sctp/sm_make_chunk.c   |   29 +++++++-
 net/sctp/socket.c          |  170 +++++++++++++++++++++++++++++++++++++++++---
 net/sctp/sysctl.c          |    7 ++
 11 files changed, 406 insertions(+), 16 deletions(-)

-- 
1.7.3.2


