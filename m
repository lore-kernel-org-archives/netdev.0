From: Francesco Fusco <ffusco@redhat.com>
Subject: [PATCH net-next 0/2] Fix overflow errors in /proc/sys/net/ipv4/neigh/
Date: Wed, 24 Jul 2013 10:39:05 +0200
Message-ID: <cover.1374654531.git.ffusco@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60256 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750991Ab3GXIjK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Jul 2013 04:39:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These two patches fix possible overflow errors in /proc/sys/net/ipv4/neigh/.

Francesco Fusco (2):
  neigh: prevent overflowing params in /proc/sys/net/ipv4/neigh/
  sysctl: range checking in do_proc_dointvec_ms_jiffies_conv

 kernel/sysctl.c      |  6 +++++-
 net/core/neighbour.c | 29 ++++++++++++++++++++++-------
 2 files changed, 27 insertions(+), 8 deletions(-)

-- 
1.8.3.1
