From: Davide Caratti <dcaratti@redhat.com>
Subject: [PATCH net-next v2 0/2] net/sched: act_csum: add support for SCTP checksum
Date: Mon,  9 Jan 2017 11:24:19 +0100
Message-ID: <cover.1483957003.git.dcaratti@redhat.com>
Cc: netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>,
        "David S . Miller" <davem@davemloft.net>,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54154 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751859AbdAIK10 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Jan 2017 05:27:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series extends current act_csum functionality to allow computation of
SCTP checksums. Patch 1 ensures LIBCRC32C will be selected if NET_ACT_CSUM
is selected. Patch 2 extends act_csum to handle IPPROTO_SCTP protocol in
IPv4/IPv6 header, and eventually compute the CRC32c value.

v2:
- style fix in tc_csum.h
- avoid nested if statement in act_csum.c

Davide Caratti (2):
  net/sched: Kconfig: select LIBCRC32C if NET_ACT_CSUM is selected
  net/sched: act_csum: compute crc32c on SCTP packets

 include/uapi/linux/tc_act/tc_csum.h |  3 ++-
 net/sched/Kconfig                   |  1 +
 net/sched/act_csum.c                | 30 ++++++++++++++++++++++++++++++
 3 files changed, 33 insertions(+), 1 deletion(-)

-- 
2.7.4
