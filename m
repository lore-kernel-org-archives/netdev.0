From: Breno Leitao <leitao@linux.vnet.ibm.com>
Subject: [PATCH net-next] e1000: Removing the unused macro PAGE_USE_COUNT()
Date: Tue, 17 Feb 2009 11:59:32 -0300
Message-ID: <499AD0D4.2000504@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp03.br.ibm.com ([32.104.18.24]:53997 "EHLO
	e24smtp03.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751966AbZBQO7h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2009 09:59:37 -0500
Received: from d24relay01.br.ibm.com (d24relay01.br.ibm.com [9.8.31.16])
	by e24smtp03.br.ibm.com (8.13.1/8.13.1) with ESMTP id n1HEvcQb026798
	for <netdev@vger.kernel.org>; Tue, 17 Feb 2009 11:57:38 -0300
Received: from d24av02.br.ibm.com (d24av02.br.ibm.com [9.18.232.47])
	by d24relay01.br.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n1HFwxu53600544
	for <netdev@vger.kernel.org>; Tue, 17 Feb 2009 12:59:00 -0300
Received: from d24av02.br.ibm.com (loopback [127.0.0.1])
	by d24av02.br.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n1HExXle004807
	for <netdev@vger.kernel.org>; Tue, 17 Feb 2009 11:59:33 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Removing the unused macro PAGE_USE_COUNT(), since there is no more reference
to it. The last reference was removed by Jesse's commit number 
630b25cdf4e3f8c0a11eb04fc8436cc36653cd58.

Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>
---
 drivers/net/e1000/e1000_main.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index ca7cd7e..61b56ca 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -1877,8 +1877,6 @@ int e1000_setup_all_rx_resources(struct e1000_adapter *adapter)
  * e1000_setup_rctl - configure the receive control registers
  * @adapter: Board private structure
  **/
-#define PAGE_USE_COUNT(S) (((S) >> PAGE_SHIFT) + \
-			(((S) & (PAGE_SIZE - 1)) ? 1 : 0))
 static void e1000_setup_rctl(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
-- 
1.6.0.2

