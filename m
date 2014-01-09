From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next 0/3] bonding: fix bond_3ad RCU usage
Date: Thu,  9 Jan 2014 11:48:27 +0100
Message-ID: <1389264510-22141-1-git-send-email-vfalico@redhat.com>
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21002 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750766AbaAIKwo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jan 2014 05:52:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While digging through bond_3ad.c I've found that the RCU usage there is
just wrong - it's used as a kind of mutex/spinlock instead of RCU.

This patchset is on top of bond_3ad.c cleanup:
http://www.spinics.net/lists/netdev/msg265447.html

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
CC: netdev@vger.kernel.org
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
