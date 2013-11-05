From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next 0/2] bonding: extend round-robin mode
Date: Tue,  5 Nov 2013 13:51:40 +0100
Message-ID: <1383655902-18744-1-git-send-email-nikolay@redhat.com>
Cc: davem@davemloft.net, andy@greyhouse.net, fubar@us.ibm.com,
	vfalico@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28910 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754421Ab3KEMzI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Nov 2013 07:55:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This small patchset adds a new option called packets_per_slave to the
bonding which aims to extend round-robin mode with the following effects:
0 - choose the slave id at random
1 - packet per slave (standard round-robin, default option value)
 >1 - transmit >1 packets per slave, switch the slaves in round-robin
Patch02 adds a description for the new option to the bonding documentation.

Best regards,
 Nikolay Aleksandrov

Nikolay Aleksandrov (2):
  bonding: extend round-robin mode with packets_per_slave
  bonding: document the new packets_per_slave option

 Documentation/networking/bonding.txt |  9 ++++++
 drivers/net/bonding/bond_main.c      | 55 ++++++++++++++++++++++++++++++++----
 drivers/net/bonding/bond_sysfs.c     | 49 ++++++++++++++++++++++++++++++++
 drivers/net/bonding/bonding.h        |  3 +-
 4 files changed, 110 insertions(+), 6 deletions(-)

-- 
1.8.1.4
