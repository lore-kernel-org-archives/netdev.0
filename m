From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 0/2] handle_ing update
Date: Sat,  9 May 2015 22:51:30 +0200
Message-ID: <cover.1431203900.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, jhs@mojatatu.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:43957 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750959AbbEIUvh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 16:51:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These are a couple of cleanups to make ingress a bit more lightweight.

Thanks!

Daniel Borkmann (2):
  net: sched: consolidate handle_ing and ing_filter
  net: sched: further simplify handle_ing

 include/linux/netdevice.h |  4 ++++
 net/core/dev.c            | 48 ++++++++++++++++-----------------------
 net/sched/sch_ingress.c   | 58 ++++++++---------------------------------------
 3 files changed, 33 insertions(+), 77 deletions(-)

-- 
1.9.3
