From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch 2.6.9-rc3] 3c59x: style change in vortex_ethtool_ops declaration
Date: Fri, 8 Oct 2004 15:11:09 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041008151109.J14378@tuxdriver.com>
References: <20041008121307.C14378@tuxdriver.com> <4166E501.4000708@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, akpm@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <4166E501.4000708@pobox.com>; from jgarzik@pobox.com on Fri, Oct 08, 2004 at 03:05:37PM -0400
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Style change suggested during patch review.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
Jeff Garzik suggested this style change while reviewing my patch to
backport the 3c59x driver from 2.6 to 2.4.

 drivers/net/3c59x.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

--- linux-2.6/drivers/net/3c59x.c.orig
+++ linux-2.6/drivers/net/3c59x.c
@@ -2888,7 +2888,7 @@ static void vortex_get_drvinfo(struct ne
 }
 
 static struct ethtool_ops vortex_ethtool_ops = {
-	.get_drvinfo =		vortex_get_drvinfo,
+	.get_drvinfo		= vortex_get_drvinfo,
 };
 
 #ifdef CONFIG_PCI
