From: Neil Jerram <neil@tigera.io>
Subject: [PATCH] Make IP 'forwarding' doc more precise
Date: Fri, 10 Mar 2017 12:24:57 +0000
Message-ID: <1489148697-5529-1-git-send-email-neil@tigera.io>
Cc: Neil Jerram <neil@tigera.io>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:35521 "EHLO
        mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965185AbdCJMZf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 07:25:35 -0500
Received: by mail-wm0-f44.google.com with SMTP id v186so9334457wmd.0
        for <netdev@vger.kernel.org>; Fri, 10 Mar 2017 04:25:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It wasn't clear if the 'forwarding' setting needs to be enabled on the
interface that packets are received from, or on the interface that
packets are forwarded to, or both.

In fact (according to my code reading) the setting is relevant on the
interface that packets are received from, so this change updates the doc
to say that.

Signed-off-by: Neil Jerram <neil@tigera.io>
---
 Documentation/networking/ip-sysctl.txt | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index fc73eeb..ab02304 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1006,7 +1006,8 @@ accept_redirects - BOOLEAN
 		FALSE (router)
 
 forwarding - BOOLEAN
-	Enable IP forwarding on this interface.
+	Enable IP forwarding on this interface.  This controls whether packets
+	received _on_ this interface can be forwarded.
 
 mc_forwarding - BOOLEAN
 	Do multicast routing. The kernel needs to be compiled with CONFIG_MROUTE
-- 
2.7.4
