From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 15/20] drivers/net/wireless/ipw2x00: remove depends on CONFIG_EXPERIMENTAL
Date: Tue, 22 Jan 2013 10:30:39 -0800
Message-ID: <1358879444-25834-16-git-send-email-keescook@chromium.org>
References: <1358879444-25834-1-git-send-email-keescook@chromium.org>
Cc: netdev@vger.kernel.org, Kees Cook <keescook@chromium.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Stanislav Yakovlev <stas.yakovlev@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.outflux.net ([198.145.64.163]:43414 "EHLO smtp.outflux.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755686Ab3AVSbP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jan 2013 13:31:15 -0500
In-Reply-To: <1358879444-25834-1-git-send-email-keescook@chromium.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The CONFIG_EXPERIMENTAL config item has not carried much meaning for a
while now and is almost always enabled by default. As agreed during the
Linux kernel summit, remove it from any "depends on" lines in Kconfigs.

CC: Stanislav Yakovlev <stas.yakovlev@gmail.com>
CC: "John W. Linville" <linville@tuxdriver.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: NetDev <netdev@vger.kernel.org>
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/wireless/ipw2x00/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ipw2x00/Kconfig b/drivers/net/wireless/ipw2x00/Kconfig
index 2715b10..91c0cb3 100644
--- a/drivers/net/wireless/ipw2x00/Kconfig
+++ b/drivers/net/wireless/ipw2x00/Kconfig
@@ -137,7 +137,7 @@ config IPW2200_PROMISCUOUS
 
 config IPW2200_QOS
         bool "Enable QoS support"
-        depends on IPW2200 && EXPERIMENTAL
+        depends on IPW2200
 
 config IPW2200_DEBUG
 	bool "Enable full debugging output in IPW2200 module."
-- 
1.7.9.5
