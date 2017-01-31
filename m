From: Andy Zhou <azhou@ovn.org>
Subject: [userspace meter v3 0/5] Userspace meter
Date: Mon, 30 Jan 2017 22:39:55 -0800
Message-ID: <1485844800-2873-1-git-send-email-azhou@ovn.org>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@ovn.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35352 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750985AbdAaHBd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 02:01:33 -0500
Received: by mail-pf0-f195.google.com with SMTP id f144so26355675pfa.2
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 23:01:33 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Repost user space meter support. This is based Jarno's original work
at: https://mail.openvswitch.org/pipermail/ovs-dev/2015-November/306304.html.
With some enhancements, and rebased to current master.

---
v1-v2: rebase and repost.
v2-v3: simplify patch 2/5. 

Andy Zhou (2):
  netdev-dummy: Add --len option for netdev-dummy/receive command
  dp-packet: Enhance packet batch APIs.

Jarno Rajahalme (3):
  dpif: Meter framework.
  ofproto: Meter translation.
  dpif-netdev: Simple DROP meter implementation.

 datapath/linux/compat/include/linux/openvswitch.h |   4 +-
 include/openvswitch/ofp-actions.h                 |   1 +
 lib/dp-packet.h                                   | 140 +++++--
 lib/dpif-netdev.c                                 | 433 ++++++++++++++++++++--
 lib/dpif-netlink.c                                |  46 ++-
 lib/dpif-provider.h                               |  29 ++
 lib/dpif.c                                        | 128 ++++++-
 lib/dpif.h                                        |  13 +-
 lib/netdev-dummy.c                                |  48 ++-
 lib/netdev-linux.c                                |   3 +-
 lib/netdev.c                                      |  24 +-
 lib/odp-execute.c                                 |  58 +--
 lib/odp-util.c                                    |  14 +
 lib/ofp-actions.c                                 |   1 +
 ofproto/ofproto-dpif-sflow.c                      |   1 +
 ofproto/ofproto-dpif-xlate.c                      |  13 +-
 ofproto/ofproto-dpif.c                            |  60 ++-
 ofproto/ofproto-provider.h                        |  13 +-
 ofproto/ofproto.c                                 |  51 +--
 tests/dpif-netdev.at                              | 106 ++++++
 tests/test-conntrack.c                            |  56 ++-
 21 files changed, 1036 insertions(+), 206 deletions(-)

-- 
1.9.1
