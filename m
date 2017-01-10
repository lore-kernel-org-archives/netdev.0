From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 0/7] warning related fixes
Date: Tue, 10 Jan 2017 10:18:09 -0800
Message-ID: <20170110181816.18991-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:35882 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1765029AbdAJSS0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 13:18:26 -0500
Received: by mail-pf0-f177.google.com with SMTP id 189so38471080pfu.3
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2017 10:18:25 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These are all patches to fix other warnings found while cleaning
up netvsc driver.

Stephen Hemminger (7):
  flow_dissector: make local function static
  vxlan: remove unused variable
  socket: make sockfs_setattr static
  dcb: validate netlink attribute link
  tcp_nv: make tcpnv_get_info static
  ipv6: make udpv6_queue_rcv_skb static
  fq_codel: fix set never used warning

 drivers/net/vxlan.c       |  3 +--
 net/core/flow_dissector.c |  4 ++--
 net/dcb/dcbnl.c           | 11 +++++++----
 net/ipv4/tcp_nv.c         |  4 ++--
 net/ipv6/udp.c            |  2 +-
 net/sched/sch_fq_codel.c  |  2 --
 net/socket.c              |  2 +-
 7 files changed, 14 insertions(+), 14 deletions(-)

-- 
2.11.0
