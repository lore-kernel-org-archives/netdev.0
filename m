From: Hannes Hering <hannes.hering@linux.vnet.ibm.com>
Subject: [PATCH 1/3] [2.6.26] memory: Introduce exports for memory notifiers
Date: Wed, 7 May 2008 14:43:01 +0200
Message-ID: <200805071443.02145.hannes.hering@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, ossrosch@linux.vnet.ibm.com,
	ossthema@de.ibm.com, raisch@de.ibm.com, themann@de.ibm.com,
	tklein@de.ibm.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.29.151]:47578 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758517AbYEGMnL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2008 08:43:11 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduces two exports to allow modules to use memory notifiers.

Signed-off-by: Hannes Hering <hering2@de.ibm.com>
---

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 8ce6de5..937e825 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -53,11 +53,13 @@ int register_memory_notifier(struct notifier_block *nb)
 {
         return blocking_notifier_chain_register(&memory_chain, nb);
 }
+EXPORT_SYMBOL(register_memory_notifier);
 
 void unregister_memory_notifier(struct notifier_block *nb)
 {
         blocking_notifier_chain_unregister(&memory_chain, nb);
 }
+EXPORT_SYMBOL(unregister_memory_notifier);
 
 /*
  * register_memory - Setup a sysfs device for a memory block
-- 
1.5.5.1
