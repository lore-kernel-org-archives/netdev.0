From: Vernon Sauder <vernoninhand@gmail.com>
Subject: Re: fix smc911x.c printf typo
Date: Tue, 18 Nov 2008 15:25:55 -0500
Message-ID: <20081118152555.60adae61@vsauder-lx.localdomain>
References: <20081116.014028.125236475.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="MP_/S96M/mSg55OPsQ2KECej9R."
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f11.google.com ([209.85.221.11]:62290 "EHLO
	mail-qy0-f11.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752605AbYKRU3G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2008 15:29:06 -0500
Received: by qyk4 with SMTP id 4so1056862qyk.13
        for <netdev@vger.kernel.org>; Tue, 18 Nov 2008 12:29:03 -0800 (PST)
In-Reply-To: <20081116.014028.125236475.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--MP_/S96M/mSg55OPsQ2KECej9R.
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

David Miller wrote:

>
>Your email client corrupted this patch, breaking up lines and making
>other modifications which make the patch not usable.
>
>Please fix this up and resubmit your change, thanks!

Sorry about that. I didn't even see it. Here it is again. I also
attached it if that works better.

From: Vernon Sauder <VernonInHand@gmail.com>

Fix printf format typo in smc911x driver.

I sent this to Dustin McIntire <dustin@sensoria.com> but the email
server rejected it.

Signed-off-by: Vernon Sauder <VernonInHand@gmail.com>
---
Patch against 2.6.28-rc4 Linus git tree.

 drivers/net/smc911x.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/smc911x.c b/drivers/net/smc911x.c
index 5051554..b965fec 100644
--- a/drivers/net/smc911x.c
+++ b/drivers/net/smc911x.c
@@ -1813,7 +1813,7 @@ static int __init smc911x_probe(struct net_device *dev)
 	val = SMC_GET_BYTE_TEST(lp);
 	DBG(SMC_DEBUG_MISC, "%s: endian probe returned 0x%04x\n", CARDNAME, val);
 	if (val != 0x87654321) {
-		printk(KERN_ERR "Invalid chip endian 0x08%x\n",val);
+		printk(KERN_ERR "Invalid chip endian 0x%08x\n",val);
 		retval = -ENODEV;
 		goto err_out;
 	}
-- 
1.5.2.4

--MP_/S96M/mSg55OPsQ2KECej9R.
Content-Type: text/x-patch; name=smc911x_typo.patch
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=smc911x_typo.patch

>From 3bca1e993a997942f02241c4725206e94bbedbc3 Mon Sep 17 00:00:00 2001
From: Vernon Sauder <VernonInHand@gmail.com>
Date: Tue, 11 Nov 2008 21:01:25 -0500
Subject: [PATCH] fix smc911x.c printf typo


Signed-off-by: Vernon Sauder <VernonInHand@gmail.com>
---
 drivers/net/smc911x.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/smc911x.c b/drivers/net/smc911x.c
index 5051554..b965fec 100644
--- a/drivers/net/smc911x.c
+++ b/drivers/net/smc911x.c
@@ -1813,7 +1813,7 @@ static int __init smc911x_probe(struct net_device *dev)
 	val = SMC_GET_BYTE_TEST(lp);
 	DBG(SMC_DEBUG_MISC, "%s: endian probe returned 0x%04x\n", CARDNAME, val);
 	if (val != 0x87654321) {
-		printk(KERN_ERR "Invalid chip endian 0x08%x\n",val);
+		printk(KERN_ERR "Invalid chip endian 0x%08x\n",val);
 		retval = -ENODEV;
 		goto err_out;
 	}
-- 
1.5.2.4


--MP_/S96M/mSg55OPsQ2KECej9R.--
