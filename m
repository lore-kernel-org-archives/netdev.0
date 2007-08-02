From: "Rami Rosen" <ramirose@gmail.com>
Subject: [RFC][PATCH] Removal of FASTROUTE definition include/linux/if_packet.h
Date: Thu, 2 Aug 2007 12:23:41 +0300
Message-ID: <eb3ff54b0708020223o521e89b9v3200e06ab296df12@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.251]:4823 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755446AbXHBJXm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Aug 2007 05:23:42 -0400
Received: by an-out-0708.google.com with SMTP id d31so90245and
        for <netdev@vger.kernel.org>; Thu, 02 Aug 2007 02:23:42 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,
  It seems that PACKET_FASTROUTE definition should be removed due to that
	fastroute is no longer supported.

Regards,
Rami Rosen
--


Signed-off-by: Rami Rosen <ramirose@gmail.com>
	
	
--- linux-2.6.23-rc1-clean/include/linux/if_packet.h	2007-05-03
12:07:59.000000000 +0300
+++ linux-2.6.23-rc1/include/linux/if_packet.h	2007-08-02
11:37:16.000000000 +0300
@@ -30,7 +30,6 @@ struct sockaddr_ll
 #define PACKET_OUTGOING		4		/* Outgoing of any type */
 /* These ones are invisible by user level */
 #define PACKET_LOOPBACK		5		/* MC/BRD frame looped back */
-#define PACKET_FASTROUTE	6		/* Fastrouted frame	*/

 /* Packet socket options */
