From: roopa@cumulusnetworks.com
Subject: [PATCH net-next v2 0/3] switchdev: support stp updates on stacked netdevices
Date: Thu, 12 Mar 2015 17:29:55 -0700
Message-ID: <1426206598-29410-1-git-send-email-roopa@cumulusnetworks.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: sfeldma@gmail.com, jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:35706 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751509AbbCMAaJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 20:30:09 -0400
Received: by pabli10 with SMTP id li10so24798258pab.2
        for <netdev@vger.kernel.org>; Thu, 12 Mar 2015 17:30:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This series moves bridge stp update api to follow the setlink/dellink
apis to propagate stp state updates to switch ports on stacked netdevs

v1 -> v2:
	fix comment
	add CONFIG_NET_SWITCHDEV checks

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Roopa Prabhu (3):
  switchdev: fix stp update API to work with layered netdevices
  bond: add support for ndo_switch_port_stp_update when bond is a
    bridge port
  team: add support for ndo_switch_port_stp_update when team dev is a
    bridge port

 drivers/net/bonding/bond_main.c |    3 +++
 drivers/net/team/team.c         |    3 +++
 include/net/switchdev.h         |    4 ++++
 net/switchdev/switchdev.c       |   30 +++++++++++++++++++++++++++++-
 4 files changed, 39 insertions(+), 1 deletion(-)

-- 
1.7.10.4
