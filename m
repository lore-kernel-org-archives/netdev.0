From: Michio Honda <micchie@sfc.wide.ad.jp>
Subject: [PATCH 0/6 v8] sctp: Auto-ASCONF patch series
Date: Thu, 28 Apr 2011 11:00:40 +0900
Message-ID: <6B8D410B-439C-433A-B8CA-E3E8685055A5@sfc.wide.ad.jp>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Honda Michio <micchie@sfc.wide.ad.jp>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Wei Yongjun <yjwei@cn.fujitsu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shonan.sfc.wide.ad.jp ([203.178.142.130]:48823 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751342Ab1D1CAm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2011 22:00:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From 983b3d3f2ffe0173f0e63af029610ce301ff397c Mon Sep 17 00:00:00 2001
From: Michio Honda <micchie@sfc.wide.ad.jp>
Date: Thu, 28 Apr 2011 10:44:57 +0900
Subject: [PATCH 0/6 v8] sctp: Auto-ASCONF patch series

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
 net/sctp/ipv6.c            |    9 +++
 net/sctp/outqueue.c        |   13 ++++
 net/sctp/protocol.c        |  151 ++++++++++++++++++++++++++++++++++++++++-
 net/sctp/sm_make_chunk.c   |   40 +++++++++++-
 net/sctp/socket.c          |  162 +++++++++++++++++++++++++++++++++++++++++---
 net/sctp/sysctl.c          |    7 ++
 11 files changed, 417 insertions(+), 15 deletions(-)

-- 
1.7.3.2


