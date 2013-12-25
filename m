From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net-next 0/2] net_sched: two improvements to sch_netem
Date: Wed, 25 Dec 2013 17:35:13 +0800
Message-ID: <1387964115-31168-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <eric.dumazet@gmail.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:27859 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751563Ab3LYJfW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Dec 2013 04:35:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset makes two improvements to sch_netem.

 patch 1/2: Make bytes on wire more precise with qdisc_pkt_len().
 patch 2/2: Add a new attribute to support 64-bit rates.

Yang Yingliang (2):
  sch_netem: more precise length of packets
  sch_netem: support of 64bit rates

 include/uapi/linux/pkt_sched.h |  1 +
 net/sched/sch_netem.c          | 17 ++++++++++++++---
 2 files changed, 15 insertions(+), 3 deletions(-)

-- 
1.8.0
