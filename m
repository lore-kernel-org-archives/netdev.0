From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 03/04] ipg: missing Kconfig dependency
Date: Sun, 28 Oct 2007 18:23:46 +0100
Message-ID: <20071028172346.GD24622@electric-eye.fr.zoreil.com>
References: <20071028171937.GA24622@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	Avuton Olrich <avuton@gmail.com>,
	Jesse Huang <jesse@icplus.com.tw>,
	Sorbica Shieh <sorbica@icplus.com.tw>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:48520 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752054AbXJ1RaQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Oct 2007 13:30:16 -0400
Content-Disposition: inline
In-Reply-To: <20071028171937.GA24622@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix for the error below while linking vmlinux:
[...]
drivers/built-in.o: In function `ipg_ioctl':
drivers/net/ipg.c:2148: undefined reference to `generic_mii_ioctl'
drivers/built-in.o: In function `ipg_get_settings':
drivers/net/ipg.c:2181: undefined reference to `mii_ethtool_gset'
drivers/built-in.o: In function `ipg_set_settings':
drivers/net/ipg.c:2193: undefined reference to `mii_ethtool_sset'
drivers/built-in.o: In function `ipg_nway_reset':
drivers/net/ipg.c:2205: undefined reference to `mii_nway_restart'
make: *** [.tmp_vmlinux1] Error 1

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Avuton Olrich <avuton@gmail.com>
Cc: Jesse Huang <jesse@icplus.com.tw>
Cc: Sorbica Shieh <sorbica@icplus.com.tw>
---
 drivers/net/Kconfig |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 86b8641..9f7ec7d 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -168,6 +168,7 @@ config NET_SB1000
 config IP1000
        tristate "IP1000 Gigabit Ethernet support"
        depends on PCI && EXPERIMENTAL
+	select MII
        ---help---
          This driver supports IP1000 gigabit Ethernet cards.
 
-- 
1.5.2.4

