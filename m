From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: BNX2 warning
Date: Fri, 21 Dec 2007 10:34:15 -0800
Message-ID: <1198262055.28427.2.camel@dell>
References: <20071220.203935.30925934.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2177 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751905AbXLURta (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Dec 2007 12:49:30 -0500
In-Reply-To: <20071220.203935.30925934.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2007-12-20 at 20:39 -0800, David Miller wrote:

> Michael, please fix this, thanks :-)
> 
> drivers/net/bnx2.c: In function 'bnx2_init_napi':
> drivers/net/bnx2.c:7329: warning: no return statement in function returning non-void
> 

[BNX2]: Fix compiler warning.

Change bnx2_init_napi() to void.

Warning was noted by DaveM.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index aef2a9a..94d1857 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -7313,7 +7313,7 @@ bnx2_bus_string(struct bnx2 *bp, char *str)
 	return str;
 }
 
-static int __devinit
+static void __devinit
 bnx2_init_napi(struct bnx2 *bp)
 {
 	int i;


