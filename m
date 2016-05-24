From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 2/3] Documentation: networking: dsa: Remove priv_size description
Date: Mon, 23 May 2016 21:32:16 -0700
Message-ID: <1464064337-8743-3-git-send-email-f.fainelli@gmail.com>
References: <1464064337-8743-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, vivien.didelot@savoirfairelinux.com,
	andrew@lunn.ch, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:35795 "EHLO
	mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751418AbcEXEcb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2016 00:32:31 -0400
Received: by mail-oi0-f65.google.com with SMTP id j202so1299486oih.2
        for <netdev@vger.kernel.org>; Mon, 23 May 2016 21:32:31 -0700 (PDT)
In-Reply-To: <1464064337-8743-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We no longer have a priv_size structure member since 5feebd0a8a79 ("net:
dsa: Remove allocation of driver private memory")

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 Documentation/networking/dsa/dsa.txt | 2 --
 1 file changed, 2 deletions(-)

diff --git a/Documentation/networking/dsa/dsa.txt b/Documentation/networking/dsa/dsa.txt
index 8303eb8ced79..411b57fd73aa 100644
--- a/Documentation/networking/dsa/dsa.txt
+++ b/Documentation/networking/dsa/dsa.txt
@@ -369,8 +369,6 @@ does not allocate any driver private context space.
 Switch configuration
 --------------------
 
-- priv_size: additional size needed by the switch driver for its private context
-
 - tag_protocol: this is to indicate what kind of tagging protocol is supported,
   should be a valid value from the dsa_tag_protocol enum
 
-- 
2.7.4
