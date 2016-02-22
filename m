From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next v2 0/2] net_sched: add network namespace support for tc actions
Date: Mon, 22 Feb 2016 15:57:51 -0800
Message-ID: <1456185473-25403-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:36409 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755831AbcBVX6C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2016 18:58:02 -0500
Received: by mail-pf0-f176.google.com with SMTP id e127so101112710pfe.3
        for <netdev@vger.kernel.org>; Mon, 22 Feb 2016 15:58:02 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset adds network namespace support for tc actions.

v2:
* pull the first patch into net-next
* reduce code duplication by introducing more helper functions

Cong Wang (2):
  net_sched: prepare tcf_hashinfo_destroy() for netns support
  net_sched: add network namespace support for tc actions

 include/net/act_api.h    |  63 ++++++++++++++++------
 net/sched/act_api.c      | 137 ++++++++++++++++++++++++++++-------------------
 net/sched/act_bpf.c      |  52 ++++++++++++++++--
 net/sched/act_connmark.c |  54 ++++++++++++++++---
 net/sched/act_csum.c     |  59 +++++++++++++++++---
 net/sched/act_gact.c     |  55 ++++++++++++++++---
 net/sched/act_ipt.c      | 127 ++++++++++++++++++++++++++++++++++++++-----
 net/sched/act_mirred.c   |  54 ++++++++++++++++---
 net/sched/act_nat.c      |  54 ++++++++++++++++---
 net/sched/act_pedit.c    |  54 ++++++++++++++++---
 net/sched/act_police.c   |  52 ++++++++++++++----
 net/sched/act_simple.c   |  55 ++++++++++++++++---
 net/sched/act_skbedit.c  |  54 ++++++++++++++++---
 net/sched/act_vlan.c     |  54 ++++++++++++++++---
 14 files changed, 771 insertions(+), 153 deletions(-)

-- 
2.1.0
