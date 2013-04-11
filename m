From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCHv2 0/2] bonding: NULL pointer dereference and flag strip fixes
Date: Thu, 11 Apr 2013 21:18:54 +0200
Message-ID: <1365707936-5073-1-git-send-email-nikolay@redhat.com>
Cc: andy@greyhouse.net, fubar@us.ibm.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43331 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752875Ab3DKTVt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Apr 2013 15:21:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 These 2 patches fix a NULL pointer dereference in the netdev event
 handling of the bond and flag that wasn't stripped on enslave failure.

v2: Fix comment style 

Nikolay Aleksandrov (2):
  bonding: fix netdev event NULL pointer dereference
  bonding: IFF_BONDING is not stripped on enslave failure

 drivers/net/bonding/bond_main.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

-- 
1.8.1.4
