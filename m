From: =?UTF-8?q?Sjur=20Br=81=E6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [RFC 2/3] if_ether.h: Add IEEE 802.1 Local Experimental Ethertype 1.
Date: Wed, 30 Nov 2011 21:44:05 +0100
Message-ID: <1322685846-7790-3-git-send-email-sjur.brandeland@stericsson.com>
References: <1322685846-7790-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Alexey Orishko <alexey.orishko@stericsson.com>,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:61187 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752490Ab1K3Uod (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 15:44:33 -0500
Received: by eaak14 with SMTP id k14so1196880eaa.19
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 12:44:32 -0800 (PST)
In-Reply-To: <1322685846-7790-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>

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
