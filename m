From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next v2 0/2] BPF update
Date: Thu,  7 Jan 2016 15:50:21 +0100
Message-ID: <cover.1452176592.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, hannes@stressinduktion.org,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:42951 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752045AbcAGOu3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 09:50:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes a csum issue on ingress. As mentioned previously, net-next
seems just fine imho. Later on, will follow up with couple of
replacements like ovs_skb_postpush_rcsum() etc.

Thanks!

v1 -> v2:
  - Added patch 1 with helper
  - Implemented Hannes' idea to just use csum_partial, thanks!

Daniel Borkmann (2):
  net, sched: add skb_at_tc_ingress helper
  bpf: add skb_postpush_rcsum and fix dev_forward_skb occasions

 include/linux/skbuff.h    | 17 +++++++++++++++++
 include/net/sch_generic.h |  9 +++++++++
 net/core/filter.c         | 17 +++++++++++++----
 net/sched/cls_bpf.c       |  6 +-----
 4 files changed, 40 insertions(+), 9 deletions(-)

-- 
1.9.3
