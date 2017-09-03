From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 5/6] nfp: build the flower offload by default
Date: Sat,  2 Sep 2017 18:26:04 -0700
Message-ID: <20170903012605.7435-6-jakub.kicinski@netronome.com>
References: <20170903012605.7435-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:33945 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752961AbdICB0S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 2 Sep 2017 21:26:18 -0400
Received: by mail-pf0-f175.google.com with SMTP id l87so9548874pfj.1
        for <netdev@vger.kernel.org>; Sat, 02 Sep 2017 18:26:17 -0700 (PDT)
In-Reply-To: <20170903012605.7435-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's reasonable to assume that if user selects to build the NFP
driver all offload capabilities will be enabled by default.
Change the CONFIG_NFP_APP_FLOWER to default to enabled.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/netronome/Kconfig b/drivers/net/ethernet/netronome/Kconfig
index 0e331e2f685a..ae0c46ba7546 100644
--- a/drivers/net/ethernet/netronome/Kconfig
+++ b/drivers/net/ethernet/netronome/Kconfig
@@ -29,6 +29,7 @@ config NFP_APP_FLOWER
 	bool "NFP4000/NFP6000 TC Flower offload support"
 	depends on NFP
 	depends on NET_SWITCHDEV
+	default y
 	---help---
 	  Enable driver support for TC Flower offload on NFP4000 and NFP6000.
 	  Say Y, if you are planning to make use of TC Flower offload
-- 
2.14.1
