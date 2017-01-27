From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] net: wan:  Remove unused stats member from struct frad_local
Date: Fri, 27 Jan 2017 15:26:32 +0100
Message-ID: <20170127142632.29332-1-tklauser@distanz.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:39628 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932257AbdA0O1F (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 27 Jan 2017 09:27:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The stats member of struct frad_locl is used neither by the dlci nor the
sdla driver, so it might as well be removed.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 include/linux/if_frad.h | 2 --
 1 file changed, 2 deletions(-)

diff --git a/include/linux/if_frad.h b/include/linux/if_frad.h
index 4316aa173dde..46df7e565d6f 100644
--- a/include/linux/if_frad.h
+++ b/include/linux/if_frad.h
@@ -66,8 +66,6 @@ struct dlci_local
 
 struct frad_local
 {
-   struct net_device_stats stats;
-
    /* devices which this FRAD is slaved to */
    struct net_device     *master[CONFIG_DLCI_MAX];
    short             dlci[CONFIG_DLCI_MAX];
-- 
2.11.0
