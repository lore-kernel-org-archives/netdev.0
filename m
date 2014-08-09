From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Subject: [PATCH] net: wireless: ipw2x00: ipw2200.c:  Cleaning up missing null-terminate after strncpy call
Date: Sun, 10 Aug 2014 01:39:28 +0200
Message-ID: <1407627568-24125-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Cc: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Stanislav Yakovlev <stas.yakovlev@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f51.google.com ([209.85.215.51]:49529 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751442AbaHIXiB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Aug 2014 19:38:01 -0400
Received: by mail-la0-f51.google.com with SMTP id pn19so5636666lab.38
        for <netdev@vger.kernel.org>; Sat, 09 Aug 2014 16:37:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added a guaranteed null-terminate after call to strncpy.

Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
---
 drivers/net/wireless/ipw2x00/ipw2200.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/wireless/ipw2x00/ipw2200.c b/drivers/net/wireless/ipw2x00/ipw2200.c
index c5aa404..389656b 100644
--- a/drivers/net/wireless/ipw2x00/ipw2200.c
+++ b/drivers/net/wireless/ipw2x00/ipw2200.c
@@ -9853,6 +9853,7 @@ static int ipw_wx_get_wireless_mode(struct net_device *dev,
 		strncpy(extra, "unknown", MAX_WX_STRING);
 		break;
 	}
+	extra[MAX_WX_STRING - 1] = '\0';
 
 	IPW_DEBUG_WX("PRIV GET MODE: %s\n", extra);
 
-- 
1.7.10.4
