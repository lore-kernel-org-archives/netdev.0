From: Tom Herbert <therbert@google.com>
Subject: [PATCH RFC net-next 0/6] net: Call skb_get_hash in net/sched
Date: Sun,  1 Mar 2015 14:09:43 -0800
Message-ID: <1425247789-21211-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:39706 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751366AbbCAWKF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2015 17:10:05 -0500
Received: by igdh15 with SMTP id h15so12760666igd.4
        for <netdev@vger.kernel.org>; Sun, 01 Mar 2015 14:10:03 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace instance of calling flow_dissect and jhash with call to
skb_get_hash. This also eliminates use of flow_keys in skb->cb[].

Tom Herbert (6):
  net: Add skb_get_hash_perturb
  sched: Eliminate use of flow_keys in sch_choke
  sched: Eliminate use of flow_keys in sch_fq_codel
  sched: Eliminate use of flow_keys in sch_hhf
  sched: Eliminate use of flow_keys in sch_sfb
  sched: Eliminate use of flow_keys in sch_sfq

 include/linux/skbuff.h   | 15 +++++++++++++++
 net/sched/sch_choke.c    | 32 ++------------------------------
 net/sched/sch_fq_codel.c | 11 ++---------
 net/sched/sch_hhf.c      | 19 +------------------
 net/sched/sch_sfb.c      | 24 ++++++++----------------
 net/sched/sch_sfq.c      | 29 +++--------------------------
 6 files changed, 31 insertions(+), 99 deletions(-)

-- 
2.2.0.rc0.207.ga3a616c
