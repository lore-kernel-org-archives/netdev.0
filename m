From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net v2 2/3] Documentation: networking: dsa: Remove priv_size description
Date: Tue, 24 May 2016 21:26:40 -0700
Message-ID: <1464150401-2318-3-git-send-email-f.fainelli@gmail.com>
References: <1464150401-2318-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, vivien.didelot@savoirfairelinux.com,
	andrew@lunn.ch, idosch@mellanox.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:36115 "EHLO
	mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750936AbcEYE0u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2016 00:26:50 -0400
Received: by mail-oi0-f65.google.com with SMTP id x130so8584296oia.3
        for <netdev@vger.kernel.org>; Tue, 24 May 2016 21:26:50 -0700 (PDT)
In-Reply-To: <1464150401-2318-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We no longer have a priv_size structure member since 5feebd0a8a79 ("net:
dsa: Remove allocation of driver private memory")

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
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
