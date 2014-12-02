From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/6] net_sched: cls_*: couple of fixes
Date: Tue,  2 Dec 2014 18:00:30 +0100
Message-ID: <1417539636-12710-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f51.google.com ([74.125.82.51]:44636 "EHLO
	mail-wg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932717AbaLBRAl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 12:00:41 -0500
Received: by mail-wg0-f51.google.com with SMTP id k14so17558617wgh.10
        for <netdev@vger.kernel.org>; Tue, 02 Dec 2014 09:00:40 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko (6):
  net_sched: cls_basic: remove unnecessary iteration and use passed arg
  net_sched: cls_bpf: remove unnecessary iteration and use passed arg
  net_sched: cls_bpf: remove faulty use of list_for_each_entry_rcu
  net_sched: cls_flow: remove faulty use of list_for_each_entry_rcu
  net_sched: cls_flow: remove duplicate assignments
  net_sched: cls_cgroup: remove unnecessary if

 net/sched/cls_basic.c  | 16 +++++-----------
 net/sched/cls_bpf.c    | 21 +++++++--------------
 net/sched/cls_cgroup.c |  6 +-----
 net/sched/cls_flow.c   |  7 ++-----
 4 files changed, 15 insertions(+), 35 deletions(-)

-- 
1.9.3
