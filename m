From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 0/2] tcp: extend access to CC information
Date: Tue, 28 Apr 2015 16:23:47 -0700
Message-ID: <1430263429-4069-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f201.google.com ([209.85.220.201]:33948 "EHLO
	mail-qk0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030957AbbD1Xb1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2015 19:31:27 -0400
Received: by qkbw1 with SMTP id w1so390247qkb.1
        for <netdev@vger.kernel.org>; Tue, 28 Apr 2015 16:31:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of being forced to use netlink, we want to get (optional) CC
information using a getsockopt() on the socket file handle.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
Cc: Neal Cardwell <ncardwell@google.com>

Eric Dumazet (2):
  tcp: prepare CC get_info() access from getsockopt()
  tcp: add TCP_CC_INFO socket option

 include/net/tcp.h              |  5 ++++-
 include/uapi/linux/inet_diag.h |  4 ++++
 include/uapi/linux/tcp.h       |  1 +
 net/ipv4/inet_diag.c           |  8 +++++---
 net/ipv4/tcp.c                 | 21 +++++++++++++++++++++
 net/ipv4/tcp_dctcp.c           | 20 ++++++++++----------
 net/ipv4/tcp_illinois.c        | 21 +++++++++++----------
 net/ipv4/tcp_vegas.c           | 19 ++++++++++---------
 net/ipv4/tcp_vegas.h           |  3 ++-
 9 files changed, 68 insertions(+), 34 deletions(-)

-- 
2.2.0.rc0.207.ga3a616c
