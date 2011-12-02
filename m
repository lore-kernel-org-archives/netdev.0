From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [PATCH 1/3] if_ether.h: Add IEEE 802.1 Local Experimental Ethertype 1.
Date: Fri,  2 Dec 2011 15:06:15 +0100
Message-ID: <1322834777-2486-2-git-send-email-sjur.brandeland@stericsson.com>
References: <1322834777-2486-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Alexey Orishko <alexey.orishko@stericsson.com>,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:49662 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756695Ab1LBOG3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2011 09:06:29 -0500
Received: by faaq16 with SMTP id q16so2045878faa.19
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2011 06:06:28 -0800 (PST)
In-Reply-To: <1322834777-2486-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add EthType 0x88b5.
This Ethertype value is available for public use for prototype and
vendor-specific protocol development,as defined in Amendment 802a
to IEEE Std 802.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 include/linux/if_ether.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/linux/if_ether.h b/include/linux/if_ether.h
index e473003..56d907a 100644
--- a/include/linux/if_ether.h
+++ b/include/linux/if_ether.h
@@ -79,6 +79,7 @@
 #define ETH_P_PAE	0x888E		/* Port Access Entity (IEEE 802.1X) */
 #define ETH_P_AOE	0x88A2		/* ATA over Ethernet		*/
 #define ETH_P_8021AD	0x88A8          /* 802.1ad Service VLAN		*/
+#define ETH_P_802_EX1	0x88B5		/* 802.1 Local Experimental 1.  */
 #define ETH_P_TIPC	0x88CA		/* TIPC 			*/
 #define ETH_P_8021AH	0x88E7          /* 802.1ah Backbone Service Tag *=
/
 #define ETH_P_1588	0x88F7		/* IEEE 1588 Timesync */
--=20
1.7.0.4
