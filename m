From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next] net: ptp: oki-semi: fix build dependency
Date: Sun, 30 Mar 2014 23:32:19 -0700
Message-ID: <1396247539-27298-1-git-send-email-ast@plumgrid.com>
Cc: Daniel Borkmann <dborkman@redhat.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:57637 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752992AbaCaGcX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2014 02:32:23 -0400
Received: by mail-pa0-f46.google.com with SMTP id kx10so2267590pab.33
        for <netdev@vger.kernel.org>; Sun, 30 Mar 2014 23:32:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fix kbuild test error:
ERROR: "ptp_classify_raw" [drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.ko] undefined!

Fixes: 164d8c666521 ("net: ptp: do not reimplement PTP/BPF classifier")
Cc: Paul Mackerras <paulus@samba.org>
Cc: linux-ppp@vger.kernel.org
Cc: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 drivers/net/ethernet/oki-semi/pch_gbe/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig b/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig
index a588ffde9700..b6f2ed76f7e4 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig
@@ -4,7 +4,7 @@
 
 config PCH_GBE
 	tristate "OKI SEMICONDUCTOR IOH(ML7223/ML7831) GbE"
-	depends on PCI && (X86 || COMPILE_TEST)
+	depends on PCI && NETWORK_PHY_TIMESTAMPING && (X86 || COMPILE_TEST)
 	select MII
 	select PTP_1588_CLOCK_PCH
 	---help---
-- 
1.7.9.5
