From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 0/2] tcp: fastopen: accept data/FIN present in SYNACK
Date: Mon,  1 Feb 2016 21:03:06 -0800
Message-ID: <1454389388-1506-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Sara Dickinson <sara@sinodun.com>,
	Yuchung Cheng <ycheng@google.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:36620 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750710AbcBBFDS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 00:03:18 -0500
Received: by mail-pf0-f182.google.com with SMTP id n128so95647957pfn.3
        for <netdev@vger.kernel.org>; Mon, 01 Feb 2016 21:03:18 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implements RFC 7413 (TCP Fast Open) 4.2.2, accepting payload and/or FIN
in SYNACK messages, and prepare removal of SYN flag in tcp_recvmsg()

Eric Dumazet (2):
  tcp: fastopen: accept data/FIN present in SYNACK message
  tcp: do not enqueue skb with SYN flag

 include/net/tcp.h       |  1 +
 net/ipv4/tcp.c          |  8 ++++--
 net/ipv4/tcp_fastopen.c | 67 +++++++++++++++++++++++++++----------------------
 net/ipv4/tcp_input.c    |  3 +++
 4 files changed, 47 insertions(+), 32 deletions(-)

-- 
2.7.0.rc3.207.g0ac5344
