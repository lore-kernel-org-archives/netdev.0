From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 6/7] atm: he: remove unnecessary pci_set_drvdata()
Date: Tue, 10 Dec 2013 12:51:46 +0900
Message-ID: <001001cef55b$25d4dfa0$717e9ee0$%han@samsung.com>
References: <000601cef55a$b605fab0$2211f010$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 'Chas Williams' <chas@cmf.nrl.navy.mil>, netdev@vger.kernel.org,
	linux-atm-general@lists.sourceforge.net,
	'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:10576 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751964Ab3LJDvr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 22:51:47 -0500
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MXK0088IO2ASO80@mailout3.samsung.com> for
 netdev@vger.kernel.org; Tue, 10 Dec 2013 12:51:46 +0900 (KST)
In-reply-to: <000601cef55a$b605fab0$2211f010$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/atm/he.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/atm/he.c b/drivers/atm/he.c
index 8557adc..aa6be26 100644
--- a/drivers/atm/he.c
+++ b/drivers/atm/he.c
@@ -419,7 +419,6 @@ static void he_remove_one(struct pci_dev *pci_dev)
 	atm_dev_deregister(atm_dev);
 	kfree(he_dev);
 
-	pci_set_drvdata(pci_dev, NULL);
 	pci_disable_device(pci_dev);
 }
 
-- 
1.7.10.4
