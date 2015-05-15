From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 0/6] neigh cleanups and fixes
Date: Fri, 15 May 2015 14:55:40 +0800
Message-ID: <1431672946-300-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <eric.dumazet@gmail.com>, <alexei@purestorage.com>,
	<joern@purestorage.com>, <ja@ssi.bg>, <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:48100 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754189AbbEOG4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 02:56:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The series aims to clean up several mistakes especially to correct
the usage of neigh timer. But before doing them, we have to resolve
a crash issue discussed in the thread[1].

[1] http://www.spinics.net/lists/netdev/msg323883.html

Ying Xue (6):
  net: fix a double free issue for neighbour entry
  neigh: fix a possible leak issue of neigh entry
  neigh: don't delete neighbour time in neigh_destroy
  neigh: align the usage of neigh timer with one of sock timer
  neigh: neigh dead and timer variables should be protected under its
    lock
  neigh: use standard interface to modify timer

 net/core/neighbour.c |   39 +++++++++++++++++++++++----------------
 net/ipv4/ip_output.c |    2 +-
 2 files changed, 24 insertions(+), 17 deletions(-)

-- 
1.7.9.5
