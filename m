From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: [PATCH 5/5] IEEE 802.15.4: do not enable driver debugging by default
Date: Thu, 30 Jun 2011 16:37:48 +0400
Message-ID: <1309437468-31021-6-git-send-email-dbaryshkov@gmail.com>
References: <1309437468-31021-1-git-send-email-dbaryshkov@gmail.com>
Cc: netdev@vger.kernel.org, Werner Almesberger <werner@almesberger.net>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:51937 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752531Ab1F3MiV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2011 08:38:21 -0400
Received: by wwe5 with SMTP id 5so2200790wwe.1
        for <netdev@vger.kernel.org>; Thu, 30 Jun 2011 05:38:19 -0700 (PDT)
In-Reply-To: <1309437468-31021-1-git-send-email-dbaryshkov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Werner Almesberger <werner@almesberger.net>

The IEEE 802.15.4 drivers were compiled by default with debugging,
which caused them to be rather chatty and slow. This patch silences
them. People debugging drivers can still add a #define DEBUG in the
beginning of the respective file or use dynamic debug

This patch also removes the now unused option CONFIG_FFD.

Signed-off-by: Werner Almesberger <werner@almesberger.net>
Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
---
 drivers/ieee802154/Makefile |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/ieee802154/Makefile b/drivers/ieee802154/Makefile
index 6899913..800a389 100644
--- a/drivers/ieee802154/Makefile
+++ b/drivers/ieee802154/Makefile
@@ -1,3 +1 @@
 obj-$(CONFIG_IEEE802154_FAKEHARD) += fakehard.o
-
-ccflags-y := -DDEBUG -DCONFIG_FFD
-- 
1.7.5.4

