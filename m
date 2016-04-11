From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH] devlink: add missing install of header
Date: Mon, 11 Apr 2016 13:39:08 -0700
Message-ID: <1460407148-24228-1-git-send-email-stephen@networkplumber.org>
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: davem@davemloft.net, jiri@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:35571 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754539AbcDKUjL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 16:39:11 -0400
Received: by mail-pf0-f174.google.com with SMTP id n1so130683745pfn.2
        for <netdev@vger.kernel.org>; Mon, 11 Apr 2016 13:39:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The new devlink.h in uapi was not being installed by
make headers_install

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
 include/uapi/linux/Kbuild | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/Kbuild b/include/uapi/linux/Kbuild
index b71fd0b..813ffb2e 100644
--- a/include/uapi/linux/Kbuild
+++ b/include/uapi/linux/Kbuild
@@ -96,6 +96,7 @@ header-y += cyclades.h
 header-y += cycx_cfm.h
 header-y += dcbnl.h
 header-y += dccp.h
+header-y += devlink.h
 header-y += dlmconstants.h
 header-y += dlm_device.h
 header-y += dlm.h
-- 
2.1.4
