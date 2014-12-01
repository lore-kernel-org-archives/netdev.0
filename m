From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 0/4] openvswitch: MPLS related fixes.
Date: Mon,  1 Dec 2014 14:30:26 -0800
Message-ID: <1417473026-2107-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog107.obsmtp.com ([74.125.149.197]:44322 "HELO
	na3sys009aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932160AbaLAWab (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2014 17:30:31 -0500
Received: by mail-pa0-f41.google.com with SMTP id rd3so12065611pab.0
        for <netdev@vger.kernel.org>; Mon, 01 Dec 2014 14:30:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First three patches fixes and improves OVS MPLS support. Last
patch is general code cleanup.

Pravin B Shelar (4):
  openvswitch: Set inner-most protocol for MPLS.
  vlan: Fix mac_len adjustment.
  mpls: Fix allowed protocols for mpls gso
  openvswitch: Fix coding style.

 net/core/skbuff.c              |    2 +-
 net/mpls/mpls_gso.c            |    5 +----
 net/openvswitch/actions.c      |    6 +++---
 net/openvswitch/datapath.c     |   11 ++++++-----
 net/openvswitch/flow.c         |   11 ++++++-----
 net/openvswitch/flow_netlink.c |   12 +++++++-----
 net/openvswitch/flow_table.c   |    3 ++-
 7 files changed, 26 insertions(+), 24 deletions(-)
