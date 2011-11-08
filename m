From: Michio Honda <micchie@sfc.wide.ad.jp>
Subject: [PATCH 0/2] sctp: Patches for fasthandoff
Date: Wed, 9 Nov 2011 01:23:01 +0900
Message-ID: <27205644-2484-4072-8689-1504958C9B73@sfc.wide.ad.jp>
Mime-Version: 1.0 (Apple Message framework v1251.1)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shonan.sfc.wide.ad.jp ([203.178.142.130]:55337 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751404Ab1KHQb5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2011 11:31:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From 0c0019a3d219bd900bedbadfa6a3b3733d9ca49c Mon Sep 17 00:00:00 2001
From: Michio Honda <micchie@sfc.wide.ad.jp>
Date: Wed, 9 Nov 2011 00:54:52 +0900
Subject: [PATCH 0/2] sctp: Patches for fasthandoff

Series of 2 patches for retransmission immediately after the address reconfiguration including disconnected period.  

Michio Honda (2):
  sctp: fasthandoff with ASCONF at mobile-node
  sctp: fasthandoff with ASCONF at server-node

 include/net/sctp/structs.h |    1 +
 net/sctp/sm_make_chunk.c   |    4 +++-
 net/sctp/sm_sideeffect.c   |    8 +++++++-
 net/sctp/transport.c       |   16 ++++++++++++++++
 4 files changed, 27 insertions(+), 2 deletions(-)

-- 
1.7.3.2
