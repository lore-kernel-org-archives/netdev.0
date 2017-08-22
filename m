From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [PATCH net-next 0/5] xdp: more work on xdp tracepoints
Date: Tue, 22 Aug 2017 22:47:14 +0200
Message-ID: <150343479290.31091.8019008896152616977.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58582 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752477AbdHVUrS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 22 Aug 2017 16:47:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

More work on streamlining the tracepoints for XDP.

I've created a simple xdp_monitor application that uses this
tracepoint, and prints statistics. Available at github:

https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/samples/bpf/xdp_monitor_kern.c
https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/samples/bpf/xdp_monitor_user.c

---

Jesper Dangaard Brouer (5):
      xdp: remove bpf_warn_invalid_xdp_redirect
      xdp: make generic xdp redirect use tracepoint trace_xdp_redirect
      ixgbe: use return codes from ndo_xdp_xmit that are distinguishable
      xdp: remove net_device names from xdp_redirect tracepoint
      xdp: get tracepoints xdp_exception and xdp_redirect in sync


 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    4 +-
 include/linux/filter.h                        |    3 +-
 include/trace/events/xdp.h                    |   33 ++++++++---------
 net/core/dev.c                                |    4 +-
 net/core/filter.c                             |   48 +++++++++++++------------
 5 files changed, 46 insertions(+), 46 deletions(-)
