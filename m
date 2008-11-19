From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] sfc: Fix dependency for SFC_MTD
Date: Wed, 19 Nov 2008 20:53:55 +0000
Message-ID: <20081119205353.GG8240@solarflare.com>
References: <20081119204850.GF8240@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	Randy Dunlap <randy.dunlap@oracle.com>,
	David Woodhouse <dwmw2@infradead.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081119204850.GF8240@solarflare.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Randy Dunlap found that SFC_MTD was selected when sfc was built-in and
the MTD core was a module.  Don't allow that combination.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

Now with S-o-b; sorry for the spam.

Ben.

diff --git a/drivers/net/sfc/Kconfig b/drivers/net/sfc/Kconfig
index 3e25fb3..c535408 100644
--- a/drivers/net/sfc/Kconfig
+++ b/drivers/net/sfc/Kconfig
@@ -14,7 +14,7 @@ config SFC
 	  will be called sfc.
 config SFC_MTD
 	bool "Solarflare Solarstorm SFC4000 flash MTD support"
-	depends on SFC && MTD
+	depends on SFC && MTD && !(SFC=y && MTD=m)
 	default y
 	help
 	  This exposes the on-board flash memory as an MTD device (e.g.
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
