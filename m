From: Veaceslav Falico <vfalico@gmail.com>
Subject: [PATCH net-next 0/2] bonding: remove rlb_enabled and alb_set_mac_address()
Date: Thu, 22 May 2014 15:12:02 +0200
Message-ID: <1400764324-23221-1-git-send-email-vfalico@gmail.com>
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25788 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752318AbaEVNQf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2014 09:16:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Currently rlb_enabled works as
rlb_enabled == (BOND_MODE(bond) == BOND_MODE_ALB)
so we can always use this verification and drop maintenance of this
variable.

alb_set_mac_address(), OTOH, isn't used at all (as the mac changing logic
is used in other parts), and isn't ever called, so it's safe to remove it
as well.

CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Andy Gospodarek <andy@greyhouse.net>
CC: netdev@vger.kernel.org
Signed-off-by: Veaceslav Falico <vfalico@gmail.com>

---
 drivers/net/bonding/bond_alb.c  | 95 ++++++-----------------------------------
 drivers/net/bonding/bond_alb.h  |  3 +-
 drivers/net/bonding/bond_main.c |  2 +-
 3 files changed, 16 insertions(+), 84 deletions(-)
