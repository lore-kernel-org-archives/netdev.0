From: Ursula Braun <ursula.braun@de.ibm.com>
Subject: [patch 1/1] [PATCH] claw: use "claw" as root device name
Date: Mon, 04 Jan 2010 14:14:45 +0100
Message-ID: <20100104131934.142015000@linux.vnet.ibm.com>
References: <20100104131444.770415000@linux.vnet.ibm.com>
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.17.161]:49673 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750738Ab0ADNTg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2010 08:19:36 -0500
Content-Disposition: inline; filename=604-claw-root-device.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

Claw module cannot be loaded together with qeth, because "qeth" has
been errorneously used as root device name. It is changed into "claw".

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---

 drivers/s390/net/claw.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -urpN linux-2.6/drivers/s390/net/claw.c linux-2.6-patched/drivers/s390/net/claw.c
--- linux-2.6/drivers/s390/net/claw.c	2010-01-04 09:04:44.000000000 +0100
+++ linux-2.6-patched/drivers/s390/net/claw.c	2010-01-04 09:04:54.000000000 +0100
@@ -3398,7 +3398,7 @@ claw_init(void)
 		goto out_err;
 	}
 	CLAW_DBF_TEXT(2, setup, "init_mod");
-	claw_root_dev = root_device_register("qeth");
+	claw_root_dev = root_device_register("claw");
 	ret = IS_ERR(claw_root_dev) ? PTR_ERR(claw_root_dev) : 0;
 	if (ret)
 		goto register_err;

