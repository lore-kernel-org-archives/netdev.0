From: =?UTF-8?q?Nicolas=20de=20Peslo=C3=BCan?=
	<nicolas.2p.debian@free.fr>
Subject: [PATCH] bonding: document undocumented active_slave sysfs entry.
Date: Mon, 26 Dec 2011 13:19:15 +0100
Message-ID: <1324901955-5816-1-git-send-email-nicolas.2p.debian@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Nicolas=20de=20Peslo=C3=BCan?=
	<nicolas.2p.debian@free.fr>, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp09.smtpout.orange.fr ([80.12.242.131]:16418 "EHLO
	smtp.smtpout.orange.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754802Ab1LZM1P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Dec 2011 07:27:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nicolas de Peslo=C3=BCan <nicolas.2p.debian@free.fr>
cc: Jay Vosburgh <fubar@us.ibm.com>
cc: Andy Gospodarek <andy@greyhouse.net>

---
 Documentation/networking/bonding.txt |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/Documentation/networking/bonding.txt b/Documentation/netwo=
rking/bonding.txt
index 91df678..83b44c2 100644
--- a/Documentation/networking/bonding.txt
+++ b/Documentation/networking/bonding.txt
@@ -196,6 +196,20 @@ or, for backwards compatibility, the option value.=
  E.g.,
=20
 	The parameters are as follows:
=20
+active_slave
+
+	Specifies the active slave for modes that support it (active-backup,
+	balance-alb and balance-tlb). The possible values are one of the
+	currently enslaved slaves. The selected slave must be up and the
+	underlying link must be up too.
+=09
+	Note that this is only available through the sysfs interface. No modu=
le
+	parameter by that name exists.
+
+	The default value is empty (no active slave). It will automatically b=
e
+	set every time an active slave is selected by normal bonding operatio=
n.
+	The current active slave can be read from this sysfs entry.
+
 ad_select
=20
 	Specifies the 802.3ad aggregation selection logic to use.  The
--=20
1.7.7.3
