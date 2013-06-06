From: nikolay@redhat.com
Subject: [PATCH 0/2] bonding: couple of bug fixes
Date: Thu,  6 Jun 2013 13:55:00 +0200
Message-ID: <1370519702-18581-1-git-send-email-nikolay@redhat.com>
Cc: andy@greyhouse.net, fubar@us.ibm.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23695 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754047Ab3FFL57 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Jun 2013 07:57:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>

Hello,
Patch 01 resets the master's mac if the first enslave fails and the slave's
mac was set to the master's prior.
Patch 02 fixes a type bug of igmp_retrans (which is the counter of igmp_resend
param and was silently not working if the value was >127) so it can go up to 255
(as per documentation). It also fixes two tricky race conditions which were
hidden because of the previous bug.

Best regards,
 Nikolay Aleksandrov

Nikolay Aleksandrov (2):
  bonding: reset master mac on first enslave failure
  bonding: fix igmp_retrans type and two related races

 drivers/net/bonding/bond_main.c | 19 +++++++++++++++----
 drivers/net/bonding/bonding.h   |  2 +-
 2 files changed, 16 insertions(+), 5 deletions(-)

-- 
1.8.1.4
