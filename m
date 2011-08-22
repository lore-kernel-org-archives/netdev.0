From: Michio Honda <micchie@sfc.wide.ad.jp>
Subject: [PATCH 0/2]  sctp: patches for HEARTBEAT bug fix and improvement
Date: Tue, 23 Aug 2011 00:44:32 +0900
Message-ID: <D42EEC2F-E0C8-4620-9841-98F7E68C88FA@sfc.wide.ad.jp>
Mime-Version: 1.0 (Apple Message framework v1244.3)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Wei Yongjun <weiyj.lk@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shonan.sfc.wide.ad.jp ([203.178.142.130]:41655 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751022Ab1HVPof convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2011 11:44:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From e7cbeb4d796fec8351ede4affbd4269346639db9 Mon Sep 17 00:00:00 2001
From: Michio Honda <micchie@sfc.wide.ad.jp>
Date: Tue, 23 Aug 2011 00:22:47 +0900
Subject: [PATCH 0/2] sctp: patches for HEARTBEAT bug fix and improvement

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


