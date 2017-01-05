From: Davide Caratti <dcaratti@redhat.com>
Subject: [PATCH net-next 0/2] net/sched: act_csum: add support for SCTP checksum
Date: Thu,  5 Jan 2017 17:59:01 +0100
Message-ID: <cover.1483630849.git.dcaratti@redhat.com>
Cc: netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>,
        "David S . Miller" <davem@davemloft.net>,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55462 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754118AbdAERAG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 5 Jan 2017 12:00:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series extends current act_csum functionality to allow computation of
SCTP checksums. Patch 1 ensures LIBCRC32C will be selected if NET_ACT_CSUM
is selected. Patch 2 extends act_csum to handle IPPROTO_SCTP protocol in
IPv4/IPv6 header, and eventually compute the CRC32c value.

Davide Caratti (2):
  net/sched: Kconfig: select LIBCRC32C if NET_ACT_CSUM is selected
  net/sched: act_csum: compute crc32c on SCTP packets

 include/uapi/linux/tc_act/tc_csum.h |  3 ++-
 net/sched/Kconfig                   |  1 +
 net/sched/act_csum.c                | 32 ++++++++++++++++++++++++++++++++
 3 files changed, 35 insertions(+), 1 deletion(-)

-- 
2.7.4
