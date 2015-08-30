From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 0/4] openvswitch: Cleanup post vport conversion.
Date: Sat, 29 Aug 2015 17:44:04 -0700
Message-ID: <1440895448-16363-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:32856 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752909AbbH3AoO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2015 20:44:14 -0400
Received: by paczk9 with SMTP id zk9so4670104pac.0
        for <netdev@vger.kernel.org>; Sat, 29 Aug 2015 17:44:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After converting all vport to netdev implmentations there
is no need for some of vport functionalify.

Pravin B Shelar (4):
  openvswitch: Remove vport get_name()
  openvswitch: Remove egress_tun_info.
  openvswitch: Remove vport stats.
  openvswitch: Remove vport-net

 net/openvswitch/actions.c            |    5 --
 net/openvswitch/datapath.c           |    1 -
 net/openvswitch/datapath.h           |    5 --
 net/openvswitch/flow.c               |    3 +-
 net/openvswitch/vport-geneve.c       |    3 +-
 net/openvswitch/vport-gre.c          |    3 +-
 net/openvswitch/vport-internal_dev.c |   58 ++++++++---------
 net/openvswitch/vport-netdev.c       |   22 ++----
 net/openvswitch/vport-netdev.h       |    2 +-
 net/openvswitch/vport-vxlan.c        |    3 +-
 net/openvswitch/vport.c              |  118 +++++-----------------------------
 net/openvswitch/vport.h              |   47 +++----------
 12 files changed, 67 insertions(+), 203 deletions(-)
