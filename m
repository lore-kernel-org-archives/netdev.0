From: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 2/2] [IrDA] Fix the AU1000 FIR dependencies
Date: Fri, 30 Jun 2006 09:56:07 +0300
Message-ID: <20060630065607.GB4729@sortiz.org>
References: <20060629154148.GA19712@stusta.de>
Reply-To: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm-3NddpPZAyC0@public.gmane.org>, linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	ralf-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	Jean-Luc Leger <reiga-dF3JGIbHi9Ffir3NkZym1w@public.gmane.org>
Return-path: <irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Adrian Bunk <bunk-HeJ8Db2Gnd6zQB+pC5nmwQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20060629154148.GA19712-HeJ8Db2Gnd6zQB+pC5nmwQ@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=irda-users>
List-Post: <mailto:irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Sender: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

AU1000 FIR is broken, it should depend on SOC_AU1000.

Spotted by Jean-Luc Leger.

Signed-off-by: Adrian Bunk <bunk-HeJ8Db2Gnd6zQB+pC5nmwQ@public.gmane.org>
Signed-off-by: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
---
 drivers/net/irda/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/irda/Kconfig b/drivers/net/irda/Kconfig
index d2ce489..e9e6d99 100644
--- a/drivers/net/irda/Kconfig
+++ b/drivers/net/irda/Kconfig
@@ -350,7 +350,7 @@ config TOSHIBA_FIR
 
 config AU1000_FIR
 	tristate "Alchemy Au1000 SIR/FIR"
-	depends on MIPS_AU1000 && IRDA
+	depends on SOC_AU1000 && IRDA
 
 config SMC_IRCC_FIR
 	tristate "SMSC IrCC (EXPERIMENTAL)"
-- 
1.4.0


Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
