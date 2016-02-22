From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [net-next PATCH 0/5] net_sched: Add support for IFE action
Date: Mon, 22 Feb 2016 08:21:39 -0500
Message-ID: <1456147304-13355-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
	xiyou.wangcong@gmail.com, alexei.starovoitov@gmail.com,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:35363 "EHLO
	mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751797AbcBVNVx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2016 08:21:53 -0500
Received: by mail-io0-f174.google.com with SMTP id g203so176273690iof.2
        for <netdev@vger.kernel.org>; Mon, 22 Feb 2016 05:21:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>


As agreed at netconf in Seville, here's the patch finally (1 year
was just too long to wait).
Described in netdev01 paper:
            "Distributing Linux Traffic Control Classifier-Action Subsystem"
             Authors: Jamal Hadi Salim and Damascene M. Joachimpillai

Allows for incremental updates for new metadatum support.
This patch set includes support for basic skb metadatum
Followup patches will have more examples of metadata

Jamal Hadi Salim (5):
  introduce IFE action
  Support to encoding decoding skb mark on IFE action
  Support to encoding decoding skb prio on IFE action
  Support to encoding decoding skb hashid on IFE action
  Support to encoding decoding skb queue map on IFE action

 include/net/tc_act/tc_ife.h        |  60 +++
 include/uapi/linux/tc_act/tc_ife.h |  38 ++
 net/sched/Kconfig                  |  32 ++
 net/sched/Makefile                 |   5 +
 net/sched/act_ife.c                | 865 +++++++++++++++++++++++++++++++++++++
 net/sched/act_meta_mark.c          |  81 ++++
 net/sched/act_meta_qmap.c          | 100 +++++
 net/sched/act_meta_skbhash.c       |  87 ++++
 net/sched/act_meta_skbprio.c       |  80 ++++
 9 files changed, 1348 insertions(+)
 create mode 100644 include/net/tc_act/tc_ife.h
 create mode 100644 include/uapi/linux/tc_act/tc_ife.h
 create mode 100644 net/sched/act_ife.c
 create mode 100644 net/sched/act_meta_mark.c
 create mode 100644 net/sched/act_meta_qmap.c
 create mode 100644 net/sched/act_meta_skbhash.c
 create mode 100644 net/sched/act_meta_skbprio.c

-- 
1.9.1
