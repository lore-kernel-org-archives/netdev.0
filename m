From: Veaceslav Falico <vfalico@gmail.com>
Subject: [PATCH net-next 0/2] bonding: add its own Kconfig
Date: Tue, 15 Jul 2014 12:15:39 +0200
Message-ID: <1405419341-31510-1-git-send-email-vfalico@gmail.com>
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Veaceslav Falico <vfalico@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10977 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758008AbaGOKUG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jul 2014 06:20:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently to change some built-in defaults it's necessary to change the
code, and to maintain these patches on each update.

Create a bonding's Kconfig to make it possible to configure them at build
time.

CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Andy Gospodarek <andy@greyhouse.net>
CC: "David S. Miller" <davem@davemloft.net>
CC: netdev@vger.kernel.org
Signed-off-by: Veaceslav Falico <vfalico@gmail.com>

---
 drivers/net/Kconfig           | 18 +-----------------
 drivers/net/bonding/Kconfig   | 33 +++++++++++++++++++++++++++++++++
 drivers/net/bonding/bonding.h |  6 +++---
 3 files changed, 37 insertions(+), 20 deletions(-)
