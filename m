From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v2 net-next 5/6] bonding: doc: some details on backup slave arp validation
Date: Thu, 20 Jun 2013 18:35:04 +0200
Message-ID: <1371746105-2482-6-git-send-email-vfalico@redhat.com>
Cc: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net,
	davem@davemloft.net, linux@8192.net, nicolas.2p.debian@free.fr,
	rick.jones2@hp.com, nikolay@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32543 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965608Ab3FTQfq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jun 2013 12:35:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add some details to bonding documentation on how backup slave arp
validation works.

Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 Documentation/networking/bonding.txt |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
index e7454fc..adee3b4 100644
--- a/Documentation/networking/bonding.txt
+++ b/Documentation/networking/bonding.txt
@@ -303,6 +303,12 @@ arp_validate
 	such a situation, validation of backup slaves must be
 	disabled.
 
+	The validation of ARP requests on backup slaves is mainly
+	helping bonding to decide which slaves are more likely to
+	work in case of the active slave failure, it doesn't really
+	guarantee that the backup slave will work if it's selected
+	as the next active slave.
+
 	This option is useful in network configurations in which
 	multiple bonding hosts are concurrently issuing ARPs to one or
 	more targets beyond a common switch.  Should the link between
-- 
1.7.1
