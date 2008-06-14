From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] sky2: 88E8040T pci device id
Date: Sat, 14 Jun 2008 10:32:15 -0700
Message-ID: <20080614103215.2bceba00@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:47008 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750744AbYFNRcV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Jun 2008 13:32:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Missed one pci id for 88E8040T.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/sky2.c	2008-06-14 09:28:04.000000000 -0700
+++ b/drivers/net/sky2.c	2008-06-14 09:27:34.000000000 -0700
@@ -118,6 +118,7 @@ static const struct pci_device_id sky2_i
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4352) }, /* 88E8038 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4353) }, /* 88E8039 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4354) }, /* 88E8040 */
+	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4355) }, /* 88E8040T */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4356) }, /* 88EC033 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4357) }, /* 88E8042 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x435A) }, /* 88E8048 */
