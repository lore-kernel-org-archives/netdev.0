From: "Wu, Bryan" <bryan.wu@analog.com>
Subject: [PATCH -mm 3/4] Blackfin: on-chip ethernet MAC controller update
	driver
Date: Wed, 21 Mar 2007 18:07:32 +0800
Message-ID: <1174471653.5648.54.camel@roc-desktop>
Reply-To: bryan.wu@analog.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: Stephen Hemminger <shemminger@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>, jgarzik@pobox.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nwd2mail10.analog.com ([137.71.25.55]:48498 "EHLO
	nwd2mail10.analog.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751831AbXCUKHh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2007 06:07:37 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi folks,

As we move 4 piece same board specific code get_bf537_ether_addr() into
arch/blackfin/mach-bf537/boards/eth_mac.c, the comment of driver should
be updated.

Signed-off-by: Bryan Wu <bryan.wu@analog.com>
---

 drivers/net/bfin_mac.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6/drivers/net/bfin_mac.c
===================================================================
--- linux-2.6.orig/drivers/net/bfin_mac.c
+++ linux-2.6/drivers/net/bfin_mac.c
@@ -842,7 +842,7 @@
        /*Is it valid? (Did bootloader initialize it?) */
        if (!is_valid_ether_addr(dev->dev_addr)) {
                /* Grab the MAC from the board somehow - this is done in the
-                  arch/blackfin/boards/bf537/boardname.c */
+                  arch/blackfin/mach-bf537/boards/eth_mac.c */
                get_bf537_ether_addr(dev->dev_addr);
        }
_

Thanks
-Bryan
