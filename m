From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 0/3] tcp: tso improvements
Date: Thu, 26 Feb 2015 14:10:17 -0800
Message-ID: <1424988620-10781-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f73.google.com ([209.85.218.73]:65147 "EHLO
	mail-oi0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753539AbbBZWLs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 17:11:48 -0500
Received: by mail-oi0-f73.google.com with SMTP id z81so4034416oif.0
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2015 14:11:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch serie reworks tcp_tso_should_defer() a bit
to get less bursts, and better ECN behavior.

We also removed tso_deferred field in tcp socket.

Eric Dumazet (3):
  tcp: tso: remove tp->tso_deferred
  tcp: tso: restore IW10 after TSO autosizing
  tcp: tso: allow CA_CWR state in tcp_tso_should_defer()

 include/linux/tcp.h   |  1 -
 net/ipv4/tcp_output.c | 29 +++++++++++++++++------------
 2 files changed, 17 insertions(+), 13 deletions(-)

-- 
2.2.0.rc0.207.ga3a616c
