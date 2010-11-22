From: Alban Crequy <alban.crequy@collabora.co.uk>
Subject: [PATCH 1/9] AF_UNIX: Add constant for Unix socket options level
Date: Mon, 22 Nov 2010 18:36:14 +0000
Message-ID: <1290450982-17480-1-git-send-email-alban.crequy@collabora.co.uk>
References: <20101122183447.124afce5@chocolatine.cbg.collabora.co.uk>
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Cyrill Gorcunov <gorcunov@openvz.org>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Lennart Poettering <lennart@poettering.net>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Ian Molton <ian.molton@collabora.co.uk>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alban Crequy <alban.crequy@collabora.co.uk>
To: Alban Crequy <alban.crequy@collabora.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101122183447.124afce5@chocolatine.cbg.collabora.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Assign the next free socket options level to be used by the Unix
protocol and address family.

Signed-off-by: Alban Crequy <alban.crequy@collabora.co.uk>
---
 include/linux/socket.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/linux/socket.h b/include/linux/socket.h
index 86b652f..7c5a4da 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -307,6 +307,7 @@ struct ucred {
 #define SOL_RDS		276
 #define SOL_IUCV	277
 #define SOL_CAIF	278
+#define SOL_UNIX	279
 
 /* IPX options */
 #define IPX_TYPE	1
-- 
1.7.1
