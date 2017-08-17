From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [PATCH 0/2] xdp: adjust xdp redirect tracepoint
Date: Thu, 17 Aug 2017 18:22:27 +0200
Message-ID: <150298692691.6608.11908184719252996949.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47520 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751637AbdHQQWa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Aug 2017 12:22:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Working on streamlining the tracepoints for XDP.  The eBPF programs
and XDP have no flow-control or queueing.  Investigating using
tracepoint to provide a feedback on XDP_REDIRECT xmit overflow events.

---

Jesper Dangaard Brouer (2):
      ixgbe: change ndo_xdp_xmit return code on xmit errors
      xdp: adjust xdp redirect tracepoint to include return error code


 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    2 +-
 include/trace/events/xdp.h                    |   11 +++++++----
 net/core/filter.c                             |   19 ++++++++++++-------
 3 files changed, 20 insertions(+), 12 deletions(-)
