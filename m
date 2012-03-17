From: Karsten Keil <isdn@linux-pingi.de>
Subject: [PATCH 11/28] mISDN: Add PCM only B-channel protocol to socket functions
Date: Sat, 17 Mar 2012 15:59:12 +0100
Message-ID: <20120423170550.4B5F29FB8D@pingi6.linux-pingi.de>
Cc: netdev@vger.kernel.org, isdn4linux@listserv.isdn4linux.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.9]:61151 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754219Ab2DWRIW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 13:08:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Karsten Keil <keil@b1-systems.de>
---
 drivers/isdn/mISDN/socket.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/isdn/mISDN/socket.c b/drivers/isdn/mISDN/socket.c
index 1254d8d..502bcf1 100644
--- a/drivers/isdn/mISDN/socket.c
+++ b/drivers/isdn/mISDN/socket.c
@@ -270,6 +270,7 @@ data_sock_release(struct socket *sock)
 		break;
 	case ISDN_P_LAPD_TE:
 	case ISDN_P_LAPD_NT:
+	case ISDN_P_B_PCM:
 	case ISDN_P_B_RAW:
 	case ISDN_P_B_HDLC:
 	case ISDN_P_B_X75SLP:
@@ -801,6 +802,7 @@ mISDN_sock_create(struct net *net, struct socket *sock, int proto, int kern)
 	case ISDN_P_NT_E1:
 	case ISDN_P_LAPD_TE:
 	case ISDN_P_LAPD_NT:
+	case ISDN_P_B_PCM:
 	case ISDN_P_B_RAW:
 	case ISDN_P_B_HDLC:
 	case ISDN_P_B_X75SLP:
-- 
1.7.3.4
