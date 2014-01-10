From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next 0/7] net_sched: some more cleanup and improvements
Date: Thu,  9 Jan 2014 16:13:58 -0800
Message-ID: <1389312845-10304-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:56436 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752691AbaAJAOg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 19:14:36 -0500
Received: by mail-pa0-f47.google.com with SMTP id kq14so3995451pab.20
        for <netdev@vger.kernel.org>; Thu, 09 Jan 2014 16:14:35 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset collects the previous patches I sent which Jamal doesn't object.
They are still some cleanup and improvements for tc actions and filters.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Cong Wang (7):
  net_sched: act: move idx_gen into struct tcf_hashinfo
  net_sched: act: clean up notification functions
  net_sched: add struct net pointer to tcf_proto_ops->dump
  net_sched: optimize tcf_match_indev()
  net_sched: avoid casting void pointer
  net_sched: cls: move allocation in ->init to generic layer
  net_sched: act: remove struct tcf_act_hdr

 include/net/act_api.h     |  11 ++---
 include/net/pkt_cls.h     |  30 ++++++------
 include/net/sch_generic.h |   3 +-
 net/sched/act_api.c       | 121 ++++++++++++++++++++--------------------------
 net/sched/act_csum.c      |   3 +-
 net/sched/act_gact.c      |   3 +-
 net/sched/act_ipt.c       |   3 +-
 net/sched/act_mirred.c    |   3 +-
 net/sched/act_nat.c       |   3 +-
 net/sched/act_pedit.c     |   3 +-
 net/sched/act_police.c    |   3 +-
 net/sched/act_simple.c    |   3 +-
 net/sched/act_skbedit.c   |   3 +-
 net/sched/cls_api.c       |  18 +++++--
 net/sched/cls_basic.c     |  20 +++-----
 net/sched/cls_bpf.c       |  13 ++---
 net/sched/cls_cgroup.c    |  23 +++------
 net/sched/cls_flow.c      |  10 ++--
 net/sched/cls_fw.c        |  49 +++++++++----------
 net/sched/cls_route.c     |  23 +++------
 net/sched/cls_rsvp.h      |  12 ++---
 net/sched/cls_tcindex.c   |  32 ++++--------
 net/sched/cls_u32.c       |  32 ++++++------
 net/sched/sch_api.c       |   1 +
 24 files changed, 178 insertions(+), 247 deletions(-)

-- 
1.8.3.1
