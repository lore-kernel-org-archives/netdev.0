From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [PATCHv2 net-next 1/4] if_ether.h: Add IEEE 802.1 Local Experimental Ethertype 1.
Date: Sun,  4 Dec 2011 11:10:47 +0100
Message-ID: <1322993450-8802-2-git-send-email-sjur.brandeland@stericsson.com>
References: <1322993450-8802-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey Orishko <alexey.orishko@stericsson.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:63713 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752492Ab1LDKLJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2011 05:11:09 -0500
Received: by eaak14 with SMTP id k14so3546710eaa.19
        for <netdev@vger.kernel.org>; Sun, 04 Dec 2011 02:11:08 -0800 (PST)
In-Reply-To: <1322993450-8802-1-git-send-email-sjur.brandeland@stericsson.com>
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
