From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] Documentation: networking: Add blurb about patches in patchwork
Date: Tue, 29 Aug 2017 15:07:51 -0700
Message-ID: <20170829220751.3814-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:36143 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751275AbdH2WH6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 18:07:58 -0400
Received: by mail-qt0-f194.google.com with SMTP id e2so3916160qta.3
        for <netdev@vger.kernel.org>; Tue, 29 Aug 2017 15:07:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Explain that the patch queue in patchwork should not be touched by patch
submitters.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 Documentation/networking/netdev-FAQ.txt | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/Documentation/networking/netdev-FAQ.txt b/Documentation/networking/netdev-FAQ.txt
index 247a30ba8e17..cfc66ea72329 100644
--- a/Documentation/networking/netdev-FAQ.txt
+++ b/Documentation/networking/netdev-FAQ.txt
@@ -111,6 +111,14 @@ A: Generally speaking, the patches get triaged quickly (in less than 48h).
    patch is a good way to ensure your patch is ignored or pushed to
    the bottom of the priority list.
 
+Q: I submitted multiple versions of the patch series, should I directly update
+   patchwork for the previous versions of these patch series?
+
+A: No, please don't interfere with the patch status on patchwork, leave it to
+   the maintainer to figure out what is the most recent and current version that
+   should be applied. If there is any doubt, the maintainer will reply and ask
+   what should be done.
+
 Q: How can I tell what patches are queued up for backporting to the
    various stable releases?
 
-- 
2.9.3
