From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: [10/9] pohmelfs: select crypto modules from the config.
Date: Tue, 10 Feb 2009 00:30:15 +0300
Message-ID: <20090209213015.GA14562@ioremap.net>
References: <1234188162-14727-1-git-send-email-zbr@ioremap.net> <1234188162-14727-2-git-send-email-zbr@ioremap.net> <1234188162-14727-3-git-send-email-zbr@ioremap.net> <1234188162-14727-4-git-send-email-zbr@ioremap.net> <1234188162-14727-5-git-send-email-zbr@ioremap.net> <1234188162-14727-6-git-send-email-zbr@ioremap.net> <1234188162-14727-7-git-send-email-zbr@ioremap.net> <1234188162-14727-8-git-send-email-zbr@ioremap.net> <1234188162-14727-9-git-send-email-zbr@ioremap.net> <1234188162-14727-10-git-send-email-zbr@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org
To: GregKH <greg@kroah.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1234188162-14727-10-git-send-email-zbr@ioremap.net>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Evgeniy Polyakov <zbr@ioremap.net>

diff --git a/drivers/staging/pohmelfs/Kconfig b/drivers/staging/pohmelfs/Kconfig
index 82d13ad..d4cbc15 100644
--- a/drivers/staging/pohmelfs/Kconfig
+++ b/drivers/staging/pohmelfs/Kconfig
@@ -1,6 +1,8 @@
 config POHMELFS
 	tristate "POHMELFS filesystem support"
 	select CONNECTOR
+	select CRYPTO_BLKCIPHER
+	select CRYPTO_HMAC
 	help
 	  POHMELFS stands for Parallel Optimized Host Message Exchange Layered File System.
 	  This is a network filesystem which supports coherent caching of data and metadata


-- 
	Evgeniy Polyakov
