From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 18/18] [TCP] FRTO: Sysctl documentation for SACK enhanced version
Date: Mon, 19 Feb 2007 13:38:12 +0200
Message-ID: <11718850923603-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11718850923446-git-send-email-ilpo.jarvinen@helsinki.fi> <1171885092563-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921459-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850923208-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921817-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850922528-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921864-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850922604-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921021-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850923324-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850922734-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921158-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921574-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921409-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921389-git-send-email-ilpo.jarvinen@helsinki.fi> <1171885092244-git-
 send-email-ilpo.jarvinen@helsinki.fi> <1171885092532-git-send-email-ilpo.jarvinen@helsinki
 .fi> <11718850923836-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Pasi Sarolahti <pasi.sarolahti@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:46068 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932139AbXBSLiV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Feb 2007 06:38:21 -0500
In-Reply-To: <11718850923836-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The description is overly verbose to avoid ambiguity between
"SACK enabled" and "SACK enhanced FRTO"

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 Documentation/networking/ip-sysctl.txt |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/net=
working/ip-sysctl.txt
index a0f6842..d66777b 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -178,7 +178,10 @@ tcp_frto - BOOLEAN
 	Enables F-RTO, an enhanced recovery algorithm for TCP retransmission
 	timeouts.  It is particularly beneficial in wireless environments
 	where packet loss is typically due to random radio interference
-	rather than intermediate router congestion.
+	rather than intermediate router congestion. If set to 1, basic
+	version is enabled. 2 enables SACK enhanced FRTO, which is
+	EXPERIMENTAL. The basic version can be used also when SACK is
+	enabled for a flow through tcp_sack sysctl.
=20
 tcp_keepalive_time - INTEGER
 	How often TCP sends out keepalive messages when keepalive is enabled.
--=20
1.4.2

