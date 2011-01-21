From: Alban Crequy <alban.crequy@collabora.co.uk>
Subject: [PATCH 2/8] af_unix: Add constant for unix socket options level
Date: Fri, 21 Jan 2011 14:39:42 +0000
Message-ID: <1295620788-6002-2-git-send-email-alban.crequy@collabora.co.uk>
References: <20110121143751.57b1453d@chocolatine.cbg.collabora.co.uk>
Cc: Alban Crequy <alban.crequy@collabora.co.uk>
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Lennart Poettering <lennart@poettering.net>,
	netdev@vger.kernel.org, linux-doc@vger.kernel.org,
	linux-
Return-path: <netdev-owner@vger.kernel.org>
Received: from bhuna.collabora.co.uk ([93.93.128.226]:57114 "EHLO
	bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753391Ab1AUOmk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jan 2011 09:42:40 -0500
In-Reply-To: <20110121143751.57b1453d@chocolatine.cbg.collabora.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Assign the next free socket options level to be used by the unix
protocol and address family.

Signed-off-by: Alban Crequy <alban.crequy@collabora.co.uk>
Reviewed-by: Ian Molton <ian.molton@collabora.co.uk>
---
 include/linux/socket.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/linux/socket.h b/include/linux/socket.h
index edbb1d0..a257d1c 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -308,6 +308,7 @@ struct ucred {
 #define SOL_IUCV	277
 #define SOL_CAIF	278
 #define SOL_ALG		279
+#define SOL_UNIX	280
 
 /* IPX options */
 #define IPX_TYPE	1
-- 
1.7.2.3

