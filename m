From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] ethtool: add names of newer Marvell chips
Date: Fri, 2 Apr 2010 08:16:32 -0700
Message-ID: <20100402081632.5401cf2f@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:38881 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751519Ab0DBPxm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Apr 2010 11:53:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fill in names of newer chips.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


diff --git a/marvell.c b/marvell.c
index 6696e0a..af38c21 100644
--- a/marvell.c
+++ b/marvell.c
@@ -184,6 +184,9 @@ static void dump_mac(const u8 *r)
 	case 0xb6:	printf("Yukon-2 EC");	break;
  	case 0xb7:	printf("Yukon-2 FE");	break;
 	case 0xb8:	printf("Yukon-2 FE Plus"); break;
+	case 0xb9:	printf("Yukon Supreme"); break;
+	case 0xba:	printf("Yukon Ultra 2"); break;
+	case 0xbc:	printf("Yukon Optima"); break;
 	default:	printf("(Unknown)");	break;
 	}
 
-- 
1.6.3.3

