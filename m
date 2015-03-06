From: roopa@cumulusnetworks.com
Subject: [PATCH net-next 0/3] switchdev: support stp updates on stacked netdevices
Date: Thu,  5 Mar 2015 20:04:15 -0800
Message-ID: <1425614658-43701-1-git-send-email-roopa@cumulusnetworks.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: sfeldma@gmail.com, jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:37238 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750965AbbCFEEZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 23:04:25 -0500
Received: by pdbnh10 with SMTP id nh10so45999445pdb.4
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2015 20:04:25 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This series moves bridge stp update api to follow the setlink/dellink
apis to propagate stp state updates to switch ports on stacked netdevs

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Roopa Prabhu (3):
  switchdev: fix stp update API to work with layered netdevices
  bond: add support for ndo_switch_port_stp_update when bond is a
    bridge port
  team: add support for ndo_switch_port_stp_update when team dev is a
    bridge port

 drivers/net/bonding/bond_main.c |    1 +
 drivers/net/team/team.c         |    1 +
 include/net/switchdev.h         |    7 +++++++
 net/switchdev/switchdev.c       |   30 +++++++++++++++++++++++++++++-
 4 files changed, 38 insertions(+), 1 deletion(-)

-- 
1.7.10.4
