From: Michio Honda <micchie@sfc.wide.ad.jp>
Subject: [PATCH 0/2]  sctp: patches for HEARTBEAT bug fix and improvement
Date: Thu, 16 Jun 2011 17:56:29 +0900
Message-ID: <306D44AC-2331-4C90-9BB8-D2A91CA8437A@sfc.wide.ad.jp>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shonan.sfc.wide.ad.jp ([203.178.142.130]:60081 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752459Ab1FPI4b convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2011 04:56:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From 111463f295a5ea7ae03c26bf62671895e803bc28 Mon Sep 17 00:00:00 2001
From: Michio Honda <micchie@sfc.wide.ad.jp>
Date: Thu, 16 Jun 2011 17:40:04 +0900
Subject: [PATCH 0/2]  sctp: patches for HEARTBEAT bug fix and improvement

Series of 2 patches for bug fix and improvement around HEARTBEAT after the 
ASCONF event

Michio Honda (2):
  sctp: HEARTBEAT negotiation after ASCONF
  sctp: Bundle HEAERTBEAT into ASCONF_ACK

 include/net/sctp/structs.h |    1 +
 net/sctp/associola.c       |    1 +
 net/sctp/outqueue.c        |    4 ++++
 net/sctp/sm_make_chunk.c   |    1 +
 net/sctp/sm_statefuns.c    |    5 +++++
 5 files changed, 12 insertions(+), 0 deletions(-)

-- 
1.7.3.2


