From: Toyo Abe <tabe@miraclelinux.com>
Subject: Re: [PATCH] TUNTAP: Fix wrong debug message
Date: Tue, 25 Dec 2007 12:27:56 +0900 (JST)
Message-ID: <20071225.122756.-713540829.tabe@miraclelinux.com>
References: <200712250153.lBP1rVXR004756@dhcp-0176.miraclelinux.com>
	<1198550928.19504.1.camel@localhost>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
 boundary="--Next_Part(Tue_Dec_25_12_27_56_2007_793)--"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, maxk@qualcomm.com
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.miraclelinux.com ([219.118.163.66]:37673 "EHLO
	mail.miraclelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751403AbXLYDgJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Dec 2007 22:36:09 -0500
In-Reply-To: <1198550928.19504.1.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

----Next_Part(Tue_Dec_25_12_27_56_2007_793)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

--- Original Messsage ---
From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] TUNTAP: Fix wrong debug message
Date: Mon, 24 Dec 2007 18:48:48 -0800
Message-ID: <1198550928.19504.1.camel@localhost>

> More readable to reverse the strings
> 
> 		    tun->dev->name, arg ? "enabled" : "disabled");
> 

Hello Joe,
Thanks for your advice.

This is the more readable version.

Best Regards,
-toyo

----Next_Part(Tue_Dec_25_12_27_56_2007_793)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline; filename="TUNTAP-Fix-wrong-debug-message.patch"

This is a trivial fix of debug message.
When a persist flag is set, the message should say "enabled".

Signed-off-by: Toyo Abe <tabe@miraclelinux.com>
---
 drivers/net/tun.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 1f76446..f8b8c71 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -610,7 +610,7 @@ static int tun_chr_ioctl(struct inode *inode, struct file *file,
 			tun->flags &= ~TUN_PERSIST;
 
 		DBG(KERN_INFO "%s: persist %s\n",
-		    tun->dev->name, arg ? "disabled" : "enabled");
+		    tun->dev->name, arg ? "enabled" : "disabled");
 		break;
 
 	case TUNSETOWNER:
-- 
1.5.3.6


----Next_Part(Tue_Dec_25_12_27_56_2007_793)----
