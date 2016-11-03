From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 0/3] qdisc and tx_queue_len cleanups for
 IFF_NO_QUEUE devices
Date: Thu, 03 Nov 2016 14:55:56 +0100
Message-ID: <20161103135534.28737.37657.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Phil Sutter <phil@nwl.cc>, Robert Olsson <robert@herjulf.se>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57496 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752131AbcKCN4A (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 3 Nov 2016 09:56:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset is a cleanup for IFF_NO_QUEUE devices.  It will
hopefully help userspace get a more consistent behavior when attaching
qdisc to such virtual devices.

---

Jesper Dangaard Brouer (3):
      net: make default TX queue length a defined constant
      net/qdisc: IFF_NO_QUEUE drivers should use consistent TX queue len
      qdisc: catch misconfig of attaching qdisc to tx_queue_len zero device


 include/net/pkt_sched.h |    2 ++
 net/core/dev.c          |    2 +-
 net/ethernet/eth.c      |    3 ++-
 net/sched/sch_api.c     |   11 +++++++++++
 4 files changed, 16 insertions(+), 2 deletions(-)
