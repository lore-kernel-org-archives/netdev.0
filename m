From: Stefan Raspl <raspl@linux.vnet.ibm.com>
Subject: [PATCH 0/2] Display adjacent switch port's attributes
Date: Wed, 11 Dec 2013 14:28:58 +0100
Message-ID: <1386768540-48188-1-git-send-email-raspl@linux.vnet.ibm.com>
Cc: bhutchings@solarflare.com, blaschka@linux.vnet.ibm.com,
	netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Stefan Raspl <raspl@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp11.uk.ibm.com ([195.75.94.107]:36900 "EHLO
	e06smtp11.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751346Ab3LKN3d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 08:29:33 -0500
Received: from /spool/local
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <raspl@linux.vnet.ibm.com>;
	Wed, 11 Dec 2013 13:29:31 -0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds a new callback for ethtool to display the adjacent switch
port's attributes, as perceived by the NIC, e.g. through respective LLDP message
exchanges.
A patch for the qeth device driver provides a sample exploiter for the new
functionality.
A new option for ethtool to display the settings will be posted in a separate
patch.

Best regards,
Stefan Raspl

Stefan Raspl (2):
  ethtool: Add callback to indicate adjacent switch port attributes
  qeth: Display adjacent switch port attributes in ethtool

 drivers/s390/net/qeth_core.h      |  7 ++++
 drivers/s390/net/qeth_core_main.c | 79 +++++++++++++++++++++++++++++++++++++++
 drivers/s390/net/qeth_core_mpc.h  | 17 +++++++++
 drivers/s390/net/qeth_l2_main.c   |  1 +
 drivers/s390/net/qeth_l3_main.c   |  1 +
 include/linux/ethtool.h           |  3 ++
 include/uapi/linux/ethtool.h      | 35 +++++++++++++++++
 net/core/ethtool.c                | 22 +++++++++++
 8 files changed, 165 insertions(+)

-- 
1.8.3.4
