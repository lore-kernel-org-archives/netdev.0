From: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Subject: [PATCH v2 net-next 0/2] tcp: simplify ack tx timestamps
Date: Wed, 27 Apr 2016 23:38:59 -0400
Message-ID: <1461814741-848-1-git-send-email-soheil.kdev@gmail.com>
Cc: kafai@fb.com, willemb@google.com, edumazet@google.com,
	ycheng@google.com, ncardwell@google.com,
	Soheil Hassas Yeganeh <soheil@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:35627 "EHLO
	mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751513AbcD1DjH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 23:39:07 -0400
Received: by mail-qk0-f196.google.com with SMTP id b63so4781324qkg.2
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 20:39:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Soheil Hassas Yeganeh <soheil@google.com>

v2:
- Fully remove SKBTX_ACK_TSTAMP, as suggested by Willem de Bruijn.

This patch series aims at removing redundant checks and fields
for ack timestamps for TCP.

Soheil Hassas Yeganeh (2):
  tcp: remove an unnecessary check in tcp_tx_timestamp
  tcp: remove SKBTX_ACK_TSTAMP since it is redundant

 include/linux/skbuff.h |  6 +-----
 net/ipv4/tcp.c         |  7 ++++---
 net/ipv4/tcp_input.c   |  3 +--
 net/ipv4/tcp_output.c  | 17 +++++++++++------
 net/socket.c           |  3 ---
 5 files changed, 17 insertions(+), 19 deletions(-)

-- 
2.8.0.rc3.226.g39d4020
