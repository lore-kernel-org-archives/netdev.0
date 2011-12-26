From: =?UTF-8?q?Nicolas=20de=20Peslo=C3=BCan?=
	<nicolas.2p.debian@free.fr>
Subject: [PATCH V2] bonding: document undocumented active_slave sysfs entry.
Date: Tue, 27 Dec 2011 00:35:24 +0100
Message-ID: <1324942524-32116-1-git-send-email-nicolas.2p.debian@free.fr>
References: <1324901955-5816-1-git-send-email-nicolas.2p.debian@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Nicolas=20de=20Peslo=C3=BCan?=
	<nicolas.2p.debian@free.fr>, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp09.smtpout.orange.fr ([80.12.242.131]:19348 "EHLO
	smtp.smtpout.orange.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752552Ab1LZXgD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Dec 2011 18:36:03 -0500
In-reply-to: <1324901955-5816-1-git-send-email-nicolas.2p.debian@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v2, based on Jay's review.

I kept the 'link must be up' part, because this is enforced in the code=
=2E

Signed-off-by: Nicolas de Peslo=C3=BCan <nicolas.2p.debian@free.fr>
Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
cc: Andy Gospodarek <andy@greyhouse.net>
---
 Documentation/networking/bonding.txt |   17 +++++++++++++++++
 1 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/Documentation/networking/bonding.txt b/Documentation/netwo=
rking/bonding.txt
index 91df678..067e715 100644
--- a/Documentation/networking/bonding.txt
+++ b/Documentation/networking/bonding.txt
@@ -196,6 +196,23 @@ or, for backwards compatibility, the option value.=
  E.g.,
=20
 	The parameters are as follows:
=20
+active_slave
+
+	Specifies the new active slave for modes that support it
+	(active-backup, balance-alb and balance-tlb).  Possible values
+	are the name of any currently enslaved interface, or an empty
+	string.  If a name is given, the slave and its link must be up in ord=
er
+	to be selected as the new active slave.  If an empty string is
+	specified, the current active slave is cleared, and a new active
+	slave is selected automatically.
+
+	Note that this is only available through the sysfs interface. No modu=
le
+	parameter by this name exists.
+
+	The normal value of this option is the name of the currently
+	active slave, or the empty string if there is no active slave or
+	the current mode does not use an active slave.
+
 ad_select
=20
 	Specifies the 802.3ad aggregation selection logic to use.  The
--=20
1.7.7.3
