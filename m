From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next 0/3] bonding: cleanup bond_3ad.c
Date: Wed,  8 Jan 2014 16:46:45 +0100
Message-ID: <1389196008-28578-1-git-send-email-vfalico@redhat.com>
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49264 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756136AbaAHPvG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jan 2014 10:51:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's a huge mess there currently - and, thus, really hard to read and
debug.

This is the first series, and doesn't change the logic at all, only makes
it a bit more readable.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>

---
 drivers/net/bonding/bond_3ad.c | 731 +++++++++++++++++++++--------------------
 1 file changed, 366 insertions(+), 365 deletions(-)
