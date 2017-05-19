From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 0/9] warning cleanups
Date: Fri, 19 May 2017 09:55:47 -0700
Message-ID: <20170519165556.483-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:35131 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752999AbdESQ4E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 12:56:04 -0400
Received: by mail-pf0-f175.google.com with SMTP id n23so42444994pfb.2
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 09:56:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series addresses a number of warnings in common networking
code visible when kernel is built with W=1

The DCB patch needs review from John Fastbend the original author
of the netlink interface since it adds missing checks.

Stephen Hemminger (9):
  dcb: enforce minimum length on IEEE_APPS attribute
  ila: propagate error code in ila_output
  udp: make local function static
  inet: fix warning about missing prototype
  tcpnv: do not export local function
  xfrm: make xfrm_dev_register static
  fou: make local function static
  ipv6: drop unused variables in seg6_genl_dumphac
  ipv6: remove unused variables in esp6

 net/dcb/dcbnl.c                 | 11 ++++--
 net/ipv4/fou.c                  | 82 ++++++++++++++++++++---------------------
 net/ipv4/inet_connection_sock.c |  1 +
 net/ipv4/tcp_nv.c               |  5 +--
 net/ipv4/udp.c                  |  2 +-
 net/ipv6/esp6.c                 |  5 ---
 net/ipv6/fou6.c                 | 14 +++----
 net/ipv6/ila/ila_lwt.c          |  2 +-
 net/ipv6/seg6.c                 |  4 --
 net/ipv6/udp.c                  |  2 +-
 net/xfrm/xfrm_device.c          |  2 +-
 11 files changed, 61 insertions(+), 69 deletions(-)

-- 
2.11.0
