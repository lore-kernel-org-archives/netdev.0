From: Jonas Johansson <jonasj76@gmail.com>
Subject: [PATCH net-next 0/2] dsa: implement HW bonding
Date: Fri, 20 Feb 2015 11:51:11 +0100
Message-ID: <1424429473-4601-1-git-send-email-jonasj76@gmail.com>
Cc: Jonas Johansson <jonas.johansson@westermo.se>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:45893 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753358AbbBTKvV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 05:51:21 -0500
Received: by labge10 with SMTP id ge10so5182159lab.12
        for <netdev@vger.kernel.org>; Fri, 20 Feb 2015 02:51:19 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jonas Johansson <jonas.johansson@westermo.se>

This patchset will implement hardware bonding support for the DSA driver and
the Marvell 88E6095 device.

Jonas Johansson (2):
  dsa: bonding: implement HW bonding
  mv88e6131: bonding: implement single device trunking

 drivers/net/dsa/mv88e6131.c | 254 ++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx.h |  14 +++
 drivers/net/team/team.c     |   4 +
 include/linux/netdevice.h   |   8 ++
 include/net/dsa.h           |   8 ++
 net/dsa/dsa.c               |  60 +++++++++++
 net/dsa/dsa_priv.h          |   6 ++
 net/dsa/slave.c             |  23 ++++
 8 files changed, 377 insertions(+)

-- 
2.1.0
