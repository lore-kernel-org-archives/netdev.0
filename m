From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next 0/2] bonding: clean rlb vlan use
Date: Thu, 29 Aug 2013 23:38:55 +0200
Message-ID: <1377812337-19551-1-git-send-email-vfalico@redhat.com>
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44372 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751625Ab3H2Vin (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Aug 2013 17:38:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Finish the vlan cleanup, only rlb left.

Remove the bond_vlan_used() function, it's useless anyway, and
rlb_client_info->tag, cause we can use only ->vlan_id.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>

---
 drivers/net/bonding/bond_alb.c | 12 +++++-------
 drivers/net/bonding/bond_alb.h |  1 -
 drivers/net/bonding/bonding.h  | 18 ------------------
 3 files changed, 5 insertions(+), 26 deletions(-)
