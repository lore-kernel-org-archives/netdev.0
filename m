From: Paul Bolle <pebolle@tiscali.nl>
Subject: [PATCH] tokenring: delete last holdout of CONFIG_TR
Date: Wed, 27 Mar 2013 21:52:28 +0100
Message-ID: <1364417548.1345.38.camel@x61.thuisdomein>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tokenring support was deleted in v3.5. One last holdout of the macro
CONFIG_TR escaped that fate. Until now.

Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
---
Untested.

 include/linux/netdevice.h | 2 --
 1 file changed, 2 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index b3d00fa..05d142f 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -144,8 +144,6 @@ static inline bool dev_xmit_complete(int rc)
 # else
 #  define LL_MAX_HEADER 96
 # endif
-#elif IS_ENABLED(CONFIG_TR)
-# define LL_MAX_HEADER 48
 #else
 # define LL_MAX_HEADER 32
 #endif
-- 
1.7.11.7
