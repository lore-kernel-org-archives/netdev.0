From: Sriram Chidambaram <schidambaram@fabric7.com>
Subject: Re: [PATCH 1/1] Fabric7 VIOC: Ethtool
Date: Tue, 24 Oct 2006 15:07:27 -0700
Message-ID: <1161727647.8112.19.camel@rh234.mv.fabric7.com>
References: <1161725441.8112.11.camel@rh234.mv.fabric7.com>
	 <20061024144620.4c9892f6@dxpl.pdx.osdl.net>
Reply-To: driver-support@fabric7.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Driver Support <driver-support@fabric7.com>,
	Jeff Garzik <jeff@garzik.org>,
	KERNEL Linux <linux-kernel@vger.kernel.org>,
	NETDEV Linux <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext-103.mv.fabric7.com ([68.120.107.103]:8491 "EHLO
	corp.fabric7.com") by vger.kernel.org with ESMTP id S1161254AbWJXWHb
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Oct 2006 18:07:31 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061024144620.4c9892f6@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Removed debug print statement

Signed-off-by: Fabric7 Driver-Support <driver-support@fabric7.com>
---
 vioc.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/vioc.c b/vioc.c
index 51004c6..c771737 100644
--- a/vioc.c
+++ b/vioc.c
@@ -17,8 +17,6 @@ int vioc_dump_regs(struct ethtool_drvinf
 	unsigned int	num_regs;
 	struct regs_line *reg_info = (struct regs_line *) regs->data;
 
-	printf("%s: Enter\n", __FUNCTION__);
-
 	printf("ethtool_regs\n"
 		"%-20s = %04x\n"
 		"%-20s = %04x\n",
-- 
1.4.3.GIT


