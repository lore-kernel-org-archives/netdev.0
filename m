From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH 08/75] ambassador: declare MODULE_FIRMWARE
Date: Sat, 07 Nov 2009 21:46:07 +0000
Message-ID: <1257630367.15927.395.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: linux-atm-general@lists.sourceforge.net,
	netdev <netdev@vger.kernel.org>
To: Chas Williams <chas@cmf.nrl.navy.mil>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:47571 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753147AbZKGVqK convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Nov 2009 16:46:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 drivers/atm/ambassador.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/atm/ambassador.c b/drivers/atm/ambassador.c
index 66e1813..8af2341 100644
--- a/drivers/atm/ambassador.c
+++ b/drivers/atm/ambassador.c
@@ -2351,6 +2351,7 @@ static void __init amb_check_args (void) {
 MODULE_AUTHOR(maintainer_string);
 MODULE_DESCRIPTION(description_string);
 MODULE_LICENSE("GPL");
+MODULE_FIRMWARE("atmsar11.fw");
 module_param(debug,   ushort, 0644);
 module_param(cmds,    uint, 0);
 module_param(txs,     uint, 0);
-- 
1.6.5.2



