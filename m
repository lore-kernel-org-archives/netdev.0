From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 0/2] bonding: extend the 3ad exported attributes
Date: Sun, 14 Jun 2015 16:36:33 +0300
Message-ID: <1434288995-25457-1-git-send-email-razor@blackwall.org>
Cc: davem@davemloft.net, gospo@cumulusnetworks.com,
	j.vosburgh@gmail.com, vfalico@gmail.com,
	Nikolay Aleksandrov <razor@blackwall.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:33220 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751342AbbFNNgp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Jun 2015 09:36:45 -0400
Received: by wiwd19 with SMTP id d19so53305606wiw.0
        for <netdev@vger.kernel.org>; Sun, 14 Jun 2015 06:36:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
These are two small patches that export actor_oper_port_state and
partner_oper_port_state via netlink and sysfs, until now they were only
exported via bond's proc entry. If this set gets accepted I have an iproute2
patch prepared that will export them with which I tested these changes.

Best regards,
 Nikolay Aleksandrov

Nikolay Aleksandrov (2):
  bonding: export slave's actor_oper_port_state via sysfs and netlink
  bonding: export slave's partner_oper_port_state via sysfs and netlink

 drivers/net/bonding/bond_netlink.c     | 15 ++++++++++++++-
 drivers/net/bonding/bond_sysfs_slave.c | 32 ++++++++++++++++++++++++++++++++
 include/uapi/linux/if_link.h           |  2 ++
 3 files changed, 48 insertions(+), 1 deletion(-)

-- 
2.4.3
