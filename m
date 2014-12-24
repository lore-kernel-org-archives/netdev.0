From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net 0/6] openvswitch: datapath fixes
Date: Tue, 23 Dec 2014 16:20:05 -0800
Message-ID: <1419380405-1515-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog104.obsmtp.com ([74.125.149.73]:41817 "HELO
	na3sys009aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754025AbaLXAUJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Dec 2014 19:20:09 -0500
Received: by mail-pd0-f177.google.com with SMTP id ft15so8771879pdb.36
        for <netdev@vger.kernel.org>; Tue, 23 Dec 2014 16:20:09 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patch series is mostly targeted to MPLS fixes. other
patches are related datapth transmit path error handling. 

Pravin B Shelar (6):
  mpls: Fix config check for mpls.
  mpls: Fix allowed protocols for mpls gso
  openvswitch: Fix MPLS action validation.
  openvswitch: Fix GSO with multiple MPLS label.
  openvswitch: Fix vport_send double free
  vxlan: Fix double free of skb.

 drivers/net/vxlan.c            |   34 ++++++++++++++++++++++++----------
 net/core/dev.c                 |    2 +-
 net/ipv4/geneve.c              |    6 +++++-
 net/mpls/mpls_gso.c            |    5 +----
 net/openvswitch/actions.c      |    3 ++-
 net/openvswitch/flow_netlink.c |   13 +------------
 net/openvswitch/vport-geneve.c |    3 +++
 net/openvswitch/vport-gre.c    |   18 +++++++++++-------
 net/openvswitch/vport-vxlan.c  |    2 ++
 net/openvswitch/vport.c        |    5 ++---
 10 files changed, 52 insertions(+), 39 deletions(-)
