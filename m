From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 0/2] tcp: more reliable window probes
Date: Wed,  6 May 2015 05:52:12 -0700
Message-ID: <1430916734-5051-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f73.google.com ([209.85.220.73]:34797 "EHLO
	mail-pa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752722AbbEFMwW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 08:52:22 -0400
Received: by pabli10 with SMTP id li10so559380pab.1
        for <netdev@vger.kernel.org>; Wed, 06 May 2015 05:52:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series address a problem caused by small rto_min timers in DC,
leading to either timer storms or early flow terminations.

Eric Dumazet (2):
  tcp: adjust window probe timers to safer values
  tcp: add TCPWinProbe SNMP counter

 include/net/tcp.h         | 27 ++++++++++++++++++++++-----
 include/uapi/linux/snmp.h |  1 +
 net/ipv4/proc.c           |  1 +
 net/ipv4/tcp_input.c      |  2 +-
 net/ipv4/tcp_output.c     |  3 ++-
 5 files changed, 27 insertions(+), 7 deletions(-)

-- 
2.2.0.rc0.207.ga3a616c
