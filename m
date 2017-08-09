From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [PATCH net-next] phylink: Fix an uninitialized variable bug
Date: Thu, 10 Aug 2017 00:35:50 +0300
Message-ID: <20170809213550.rga6tlohagu2pm2y@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>,
        Russell King <rmk+kernel@arm.linux.org.uk>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"ret" isn't necessarily initialized here.

Fixes: 9525ae83959b ("phylink: add phylink infrastructure")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/phy/phylink.c b/drivers/net/phy/phylink.c
index 32917bdd1432..bcb4755bcd95 100644
--- a/drivers/net/phy/phylink.c
+++ b/drivers/net/phy/phylink.c
@@ -958,7 +958,7 @@ int phylink_ethtool_ksettings_set(struct phylink *pl,
 	}
 	mutex_unlock(&pl->state_mutex);
 
-	return ret;
+	return 0;
 }
 EXPORT_SYMBOL_GPL(phylink_ethtool_ksettings_set);
 
