From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after final merge (net tree)
Date: Thu, 18 Feb 2010 23:33:21 -0800 (PST)
Message-ID: <20100218.233321.226788593.davem@davemloft.net>
References: <20100219173713.e3f9f386.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, kristoffer@gaisler.com
To: sfr@canb.auug.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100219173713.e3f9f386.sfr@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Fri, 19 Feb 2010 17:37:13 +1100

> I assume that this driver was written and tested only on Sparc
> ... maybe it should depend on SPARC?

Indeed, it should.  I thought for some reason that all OF
platforms have of_remap() and of_device->resource[], oh
well :-)

Will commit the following, thanks!

net: Make GRETH driver depend on SPARC.

Reported by Stephen Rothwell.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 17ff15f..46af867 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -997,7 +997,7 @@ config ETHOC
 
 config GRETH
 	tristate "Aeroflex Gaisler GRETH Ethernet MAC support"
-	depends on OF
+	depends on SPARC
 	select PHYLIB
 	select CRC32
 	help
-- 
1.6.6.1
