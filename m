From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 0/2] tcp: improve source port selection
Date: Wed, 20 May 2015 10:59:00 -0700
Message-ID: <1432144742-17786-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f73.google.com ([209.85.220.73]:33422 "EHLO
	mail-pa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753632AbbETR7G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 13:59:06 -0400
Received: by pablf10 with SMTP id lf10so1653774pab.0
        for <netdev@vger.kernel.org>; Wed, 20 May 2015 10:59:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With increase of TCP sockets in hosts, we often hit limitations
caused by port selection, due to randomization and poor strategy.

Eric Dumazet (2):
  inet_hashinfo: remove bsocket counter
  tcp: improve REUSEADDR/NOREUSEADDR cohabitation

 include/net/inet_hashtables.h   |  2 --
 net/ipv4/inet_connection_sock.c | 19 ++++++++++++++-----
 net/ipv4/inet_hashtables.c      |  7 -------
 3 files changed, 14 insertions(+), 14 deletions(-)

-- 
2.2.0.rc0.207.ga3a616c
