From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 2/4] irda: move drivers/net/irda to drivers/staging/irda/drivers
Date: Sun, 27 Aug 2017 17:03:32 +0200
Message-ID: <20170827150334.32495-3-gregkh@linuxfoundation.org>
References: <20170827150334.32495-1-gregkh@linuxfoundation.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        devel@driverdev.osuosl.org,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: davem@davemloft.net, samuel@sortiz.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170827150334.32495-1-gregkh@linuxfoundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move the irda drivers from drivers/net/irda/ to
drivers/staging/irda/drivers as they will be deleted in a future kernel
release.

Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 drivers/net/Makefile                                        | 1 -
 drivers/staging/Makefile                                    | 1 +
 drivers/{net/irda => staging/irda/drivers}/Kconfig          | 0
 drivers/{net/irda => staging/irda/drivers}/Makefile         | 0
 drivers/{net/irda => staging/irda/drivers}/act200l-sir.c    | 0
 drivers/{net/irda => staging/irda/drivers}/actisys-sir.c    | 0
 drivers/{net/irda => staging/irda/drivers}/ali-ircc.c       | 0
 drivers/{net/irda => staging/irda/drivers}/ali-ircc.h       | 0
 drivers/{net/irda => staging/irda/drivers}/au1k_ir.c        | 0
 drivers/{net/irda => staging/irda/drivers}/bfin_sir.c       | 0
 drivers/{net/irda => staging/irda/drivers}/bfin_sir.h       | 0
 drivers/{net/irda => staging/irda/drivers}/donauboe.c       | 0
 drivers/{net/irda => staging/irda/drivers}/donauboe.h       | 0
 drivers/{net/irda => staging/irda/drivers}/esi-sir.c        | 0
 drivers/{net/irda => staging/irda/drivers}/girbil-sir.c     | 0
 drivers/{net/irda => staging/irda/drivers}/irda-usb.c       | 0
 drivers/{net/irda => staging/irda/drivers}/irda-usb.h       | 0
 drivers/{net/irda => staging/irda/drivers}/irtty-sir.c      | 0
 drivers/{net/irda => staging/irda/drivers}/irtty-sir.h      | 0
 drivers/{net/irda => staging/irda/drivers}/kingsun-sir.c    | 0
 drivers/{net/irda => staging/irda/drivers}/ks959-sir.c      | 0
 drivers/{net/irda => staging/irda/drivers}/ksdazzle-sir.c   | 0
 drivers/{net/irda => staging/irda/drivers}/litelink-sir.c   | 0
 drivers/{net/irda => staging/irda/drivers}/ma600-sir.c      | 0
 drivers/{net/irda => staging/irda/drivers}/mcp2120-sir.c    | 0
 drivers/{net/irda => staging/irda/drivers}/mcs7780.c        | 0
 drivers/{net/irda => staging/irda/drivers}/mcs7780.h        | 0
 drivers/{net/irda => staging/irda/drivers}/nsc-ircc.c       | 0
 drivers/{net/irda => staging/irda/drivers}/nsc-ircc.h       | 0
 drivers/{net/irda => staging/irda/drivers}/old_belkin-sir.c | 0
 drivers/{net/irda => staging/irda/drivers}/pxaficp_ir.c     | 0
 drivers/{net/irda => staging/irda/drivers}/sa1100_ir.c      | 0
 drivers/{net/irda => staging/irda/drivers}/sh_sir.c         | 0
 drivers/{net/irda => staging/irda/drivers}/sir-dev.h        | 0
 drivers/{net/irda => staging/irda/drivers}/sir_dev.c        | 0
 drivers/{net/irda => staging/irda/drivers}/sir_dongle.c     | 0
 drivers/{net/irda => staging/irda/drivers}/smsc-ircc2.c     | 0
 drivers/{net/irda => staging/irda/drivers}/smsc-ircc2.h     | 0
 drivers/{net/irda => staging/irda/drivers}/smsc-sio.h       | 0
 drivers/{net/irda => staging/irda/drivers}/stir4200.c       | 0
 drivers/{net/irda => staging/irda/drivers}/tekram-sir.c     | 0
 drivers/{net/irda => staging/irda/drivers}/toim3232-sir.c   | 0
 drivers/{net/irda => staging/irda/drivers}/via-ircc.c       | 0
 drivers/{net/irda => staging/irda/drivers}/via-ircc.h       | 0
 drivers/{net/irda => staging/irda/drivers}/vlsi_ir.c        | 0
 drivers/{net/irda => staging/irda/drivers}/vlsi_ir.h        | 0
 drivers/{net/irda => staging/irda/drivers}/w83977af.h       | 0
 drivers/{net/irda => staging/irda/drivers}/w83977af_ir.c    | 0
 drivers/{net/irda => staging/irda/drivers}/w83977af_ir.h    | 0
 drivers/staging/irda/net/Kconfig                            | 2 +-
 50 files changed, 2 insertions(+), 2 deletions(-)
 rename drivers/{net/irda => staging/irda/drivers}/Kconfig (100%)
 rename drivers/{net/irda => staging/irda/drivers}/Makefile (100%)
 rename drivers/{net/irda => staging/irda/drivers}/act200l-sir.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/actisys-sir.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/ali-ircc.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/ali-ircc.h (100%)
 rename drivers/{net/irda => staging/irda/drivers}/au1k_ir.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/bfin_sir.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/bfin_sir.h (100%)
 rename drivers/{net/irda => staging/irda/drivers}/donauboe.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/donauboe.h (100%)
 rename drivers/{net/irda => staging/irda/drivers}/esi-sir.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/girbil-sir.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/irda-usb.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/irda-usb.h (100%)
 rename drivers/{net/irda => staging/irda/drivers}/irtty-sir.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/irtty-sir.h (100%)
 rename drivers/{net/irda => staging/irda/drivers}/kingsun-sir.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/ks959-sir.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/ksdazzle-sir.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/litelink-sir.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/ma600-sir.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/mcp2120-sir.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/mcs7780.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/mcs7780.h (100%)
 rename drivers/{net/irda => staging/irda/drivers}/nsc-ircc.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/nsc-ircc.h (100%)
 rename drivers/{net/irda => staging/irda/drivers}/old_belkin-sir.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/pxaficp_ir.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/sa1100_ir.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/sh_sir.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/sir-dev.h (100%)
 rename drivers/{net/irda => staging/irda/drivers}/sir_dev.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/sir_dongle.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/smsc-ircc2.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/smsc-ircc2.h (100%)
 rename drivers/{net/irda => staging/irda/drivers}/smsc-sio.h (100%)
 rename drivers/{net/irda => staging/irda/drivers}/stir4200.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/tekram-sir.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/toim3232-sir.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/via-ircc.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/via-ircc.h (100%)
 rename drivers/{net/irda => staging/irda/drivers}/vlsi_ir.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/vlsi_ir.h (100%)
 rename drivers/{net/irda => staging/irda/drivers}/w83977af.h (100%)
 rename drivers/{net/irda => staging/irda/drivers}/w83977af_ir.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/w83977af_ir.h (100%)

diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index b2f6556d8848..8dff900085d6 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -45,7 +45,6 @@ obj-$(CONFIG_ETHERNET) += ethernet/
 obj-$(CONFIG_FDDI) += fddi/
 obj-$(CONFIG_HIPPI) += hippi/
 obj-$(CONFIG_HAMRADIO) += hamradio/
-obj-$(CONFIG_IRDA) += irda/
 obj-$(CONFIG_PLIP) += plip/
 obj-$(CONFIG_PPP) += ppp/
 obj-$(CONFIG_PPP_ASYNC) += ppp/
diff --git a/drivers/staging/Makefile b/drivers/staging/Makefile
index 509fbacf9a7e..fced929a0e67 100644
--- a/drivers/staging/Makefile
+++ b/drivers/staging/Makefile
@@ -3,6 +3,7 @@
 obj-y				+= media/
 obj-y				+= typec/
 obj-$(CONFIG_IRDA)		+= irda/net/
+obj-$(CONFIG_IRDA)		+= irda/drivers/
 obj-$(CONFIG_PRISM2_USB)	+= wlan-ng/
 obj-$(CONFIG_COMEDI)		+= comedi/
 obj-$(CONFIG_FB_OLPC_DCON)	+= olpc_dcon/
diff --git a/drivers/net/irda/Kconfig b/drivers/staging/irda/drivers/Kconfig
similarity index 100%
rename from drivers/net/irda/Kconfig
rename to drivers/staging/irda/drivers/Kconfig
diff --git a/drivers/net/irda/Makefile b/drivers/staging/irda/drivers/Makefile
similarity index 100%
rename from drivers/net/irda/Makefile
rename to drivers/staging/irda/drivers/Makefile
diff --git a/drivers/net/irda/act200l-sir.c b/drivers/staging/irda/drivers/act200l-sir.c
similarity index 100%
rename from drivers/net/irda/act200l-sir.c
rename to drivers/staging/irda/drivers/act200l-sir.c
diff --git a/drivers/net/irda/actisys-sir.c b/drivers/staging/irda/drivers/actisys-sir.c
similarity index 100%
rename from drivers/net/irda/actisys-sir.c
rename to drivers/staging/irda/drivers/actisys-sir.c
diff --git a/drivers/net/irda/ali-ircc.c b/drivers/staging/irda/drivers/ali-ircc.c
similarity index 100%
rename from drivers/net/irda/ali-ircc.c
rename to drivers/staging/irda/drivers/ali-ircc.c
diff --git a/drivers/net/irda/ali-ircc.h b/drivers/staging/irda/drivers/ali-ircc.h
similarity index 100%
rename from drivers/net/irda/ali-ircc.h
rename to drivers/staging/irda/drivers/ali-ircc.h
diff --git a/drivers/net/irda/au1k_ir.c b/drivers/staging/irda/drivers/au1k_ir.c
similarity index 100%
rename from drivers/net/irda/au1k_ir.c
rename to drivers/staging/irda/drivers/au1k_ir.c
diff --git a/drivers/net/irda/bfin_sir.c b/drivers/staging/irda/drivers/bfin_sir.c
similarity index 100%
rename from drivers/net/irda/bfin_sir.c
rename to drivers/staging/irda/drivers/bfin_sir.c
diff --git a/drivers/net/irda/bfin_sir.h b/drivers/staging/irda/drivers/bfin_sir.h
similarity index 100%
rename from drivers/net/irda/bfin_sir.h
rename to drivers/staging/irda/drivers/bfin_sir.h
diff --git a/drivers/net/irda/donauboe.c b/drivers/staging/irda/drivers/donauboe.c
similarity index 100%
rename from drivers/net/irda/donauboe.c
rename to drivers/staging/irda/drivers/donauboe.c
diff --git a/drivers/net/irda/donauboe.h b/drivers/staging/irda/drivers/donauboe.h
similarity index 100%
rename from drivers/net/irda/donauboe.h
rename to drivers/staging/irda/drivers/donauboe.h
diff --git a/drivers/net/irda/esi-sir.c b/drivers/staging/irda/drivers/esi-sir.c
similarity index 100%
rename from drivers/net/irda/esi-sir.c
rename to drivers/staging/irda/drivers/esi-sir.c
diff --git a/drivers/net/irda/girbil-sir.c b/drivers/staging/irda/drivers/girbil-sir.c
similarity index 100%
rename from drivers/net/irda/girbil-sir.c
rename to drivers/staging/irda/drivers/girbil-sir.c
diff --git a/drivers/net/irda/irda-usb.c b/drivers/staging/irda/drivers/irda-usb.c
similarity index 100%
rename from drivers/net/irda/irda-usb.c
rename to drivers/staging/irda/drivers/irda-usb.c
diff --git a/drivers/net/irda/irda-usb.h b/drivers/staging/irda/drivers/irda-usb.h
similarity index 100%
rename from drivers/net/irda/irda-usb.h
rename to drivers/staging/irda/drivers/irda-usb.h
diff --git a/drivers/net/irda/irtty-sir.c b/drivers/staging/irda/drivers/irtty-sir.c
similarity index 100%
rename from drivers/net/irda/irtty-sir.c
rename to drivers/staging/irda/drivers/irtty-sir.c
diff --git a/drivers/net/irda/irtty-sir.h b/drivers/staging/irda/drivers/irtty-sir.h
similarity index 100%
rename from drivers/net/irda/irtty-sir.h
rename to drivers/staging/irda/drivers/irtty-sir.h
diff --git a/drivers/net/irda/kingsun-sir.c b/drivers/staging/irda/drivers/kingsun-sir.c
similarity index 100%
rename from drivers/net/irda/kingsun-sir.c
rename to drivers/staging/irda/drivers/kingsun-sir.c
diff --git a/drivers/net/irda/ks959-sir.c b/drivers/staging/irda/drivers/ks959-sir.c
similarity index 100%
rename from drivers/net/irda/ks959-sir.c
rename to drivers/staging/irda/drivers/ks959-sir.c
diff --git a/drivers/net/irda/ksdazzle-sir.c b/drivers/staging/irda/drivers/ksdazzle-sir.c
similarity index 100%
rename from drivers/net/irda/ksdazzle-sir.c
rename to drivers/staging/irda/drivers/ksdazzle-sir.c
diff --git a/drivers/net/irda/litelink-sir.c b/drivers/staging/irda/drivers/litelink-sir.c
similarity index 100%
rename from drivers/net/irda/litelink-sir.c
rename to drivers/staging/irda/drivers/litelink-sir.c
diff --git a/drivers/net/irda/ma600-sir.c b/drivers/staging/irda/drivers/ma600-sir.c
similarity index 100%
rename from drivers/net/irda/ma600-sir.c
rename to drivers/staging/irda/drivers/ma600-sir.c
diff --git a/drivers/net/irda/mcp2120-sir.c b/drivers/staging/irda/drivers/mcp2120-sir.c
similarity index 100%
rename from drivers/net/irda/mcp2120-sir.c
rename to drivers/staging/irda/drivers/mcp2120-sir.c
diff --git a/drivers/net/irda/mcs7780.c b/drivers/staging/irda/drivers/mcs7780.c
similarity index 100%
rename from drivers/net/irda/mcs7780.c
rename to drivers/staging/irda/drivers/mcs7780.c
diff --git a/drivers/net/irda/mcs7780.h b/drivers/staging/irda/drivers/mcs7780.h
similarity index 100%
rename from drivers/net/irda/mcs7780.h
rename to drivers/staging/irda/drivers/mcs7780.h
diff --git a/drivers/net/irda/nsc-ircc.c b/drivers/staging/irda/drivers/nsc-ircc.c
similarity index 100%
rename from drivers/net/irda/nsc-ircc.c
rename to drivers/staging/irda/drivers/nsc-ircc.c
diff --git a/drivers/net/irda/nsc-ircc.h b/drivers/staging/irda/drivers/nsc-ircc.h
similarity index 100%
rename from drivers/net/irda/nsc-ircc.h
rename to drivers/staging/irda/drivers/nsc-ircc.h
diff --git a/drivers/net/irda/old_belkin-sir.c b/drivers/staging/irda/drivers/old_belkin-sir.c
similarity index 100%
rename from drivers/net/irda/old_belkin-sir.c
rename to drivers/staging/irda/drivers/old_belkin-sir.c
diff --git a/drivers/net/irda/pxaficp_ir.c b/drivers/staging/irda/drivers/pxaficp_ir.c
similarity index 100%
rename from drivers/net/irda/pxaficp_ir.c
rename to drivers/staging/irda/drivers/pxaficp_ir.c
diff --git a/drivers/net/irda/sa1100_ir.c b/drivers/staging/irda/drivers/sa1100_ir.c
similarity index 100%
rename from drivers/net/irda/sa1100_ir.c
rename to drivers/staging/irda/drivers/sa1100_ir.c
diff --git a/drivers/net/irda/sh_sir.c b/drivers/staging/irda/drivers/sh_sir.c
similarity index 100%
rename from drivers/net/irda/sh_sir.c
rename to drivers/staging/irda/drivers/sh_sir.c
diff --git a/drivers/net/irda/sir-dev.h b/drivers/staging/irda/drivers/sir-dev.h
similarity index 100%
rename from drivers/net/irda/sir-dev.h
rename to drivers/staging/irda/drivers/sir-dev.h
diff --git a/drivers/net/irda/sir_dev.c b/drivers/staging/irda/drivers/sir_dev.c
similarity index 100%
rename from drivers/net/irda/sir_dev.c
rename to drivers/staging/irda/drivers/sir_dev.c
diff --git a/drivers/net/irda/sir_dongle.c b/drivers/staging/irda/drivers/sir_dongle.c
similarity index 100%
rename from drivers/net/irda/sir_dongle.c
rename to drivers/staging/irda/drivers/sir_dongle.c
diff --git a/drivers/net/irda/smsc-ircc2.c b/drivers/staging/irda/drivers/smsc-ircc2.c
similarity index 100%
rename from drivers/net/irda/smsc-ircc2.c
rename to drivers/staging/irda/drivers/smsc-ircc2.c
diff --git a/drivers/net/irda/smsc-ircc2.h b/drivers/staging/irda/drivers/smsc-ircc2.h
similarity index 100%
rename from drivers/net/irda/smsc-ircc2.h
rename to drivers/staging/irda/drivers/smsc-ircc2.h
diff --git a/drivers/net/irda/smsc-sio.h b/drivers/staging/irda/drivers/smsc-sio.h
similarity index 100%
rename from drivers/net/irda/smsc-sio.h
rename to drivers/staging/irda/drivers/smsc-sio.h
diff --git a/drivers/net/irda/stir4200.c b/drivers/staging/irda/drivers/stir4200.c
similarity index 100%
rename from drivers/net/irda/stir4200.c
rename to drivers/staging/irda/drivers/stir4200.c
diff --git a/drivers/net/irda/tekram-sir.c b/drivers/staging/irda/drivers/tekram-sir.c
similarity index 100%
rename from drivers/net/irda/tekram-sir.c
rename to drivers/staging/irda/drivers/tekram-sir.c
diff --git a/drivers/net/irda/toim3232-sir.c b/drivers/staging/irda/drivers/toim3232-sir.c
similarity index 100%
rename from drivers/net/irda/toim3232-sir.c
rename to drivers/staging/irda/drivers/toim3232-sir.c
diff --git a/drivers/net/irda/via-ircc.c b/drivers/staging/irda/drivers/via-ircc.c
similarity index 100%
rename from drivers/net/irda/via-ircc.c
rename to drivers/staging/irda/drivers/via-ircc.c
diff --git a/drivers/net/irda/via-ircc.h b/drivers/staging/irda/drivers/via-ircc.h
similarity index 100%
rename from drivers/net/irda/via-ircc.h
rename to drivers/staging/irda/drivers/via-ircc.h
diff --git a/drivers/net/irda/vlsi_ir.c b/drivers/staging/irda/drivers/vlsi_ir.c
similarity index 100%
rename from drivers/net/irda/vlsi_ir.c
rename to drivers/staging/irda/drivers/vlsi_ir.c
diff --git a/drivers/net/irda/vlsi_ir.h b/drivers/staging/irda/drivers/vlsi_ir.h
similarity index 100%
rename from drivers/net/irda/vlsi_ir.h
rename to drivers/staging/irda/drivers/vlsi_ir.h
diff --git a/drivers/net/irda/w83977af.h b/drivers/staging/irda/drivers/w83977af.h
similarity index 100%
rename from drivers/net/irda/w83977af.h
rename to drivers/staging/irda/drivers/w83977af.h
diff --git a/drivers/net/irda/w83977af_ir.c b/drivers/staging/irda/drivers/w83977af_ir.c
similarity index 100%
rename from drivers/net/irda/w83977af_ir.c
rename to drivers/staging/irda/drivers/w83977af_ir.c
diff --git a/drivers/net/irda/w83977af_ir.h b/drivers/staging/irda/drivers/w83977af_ir.h
similarity index 100%
rename from drivers/net/irda/w83977af_ir.h
rename to drivers/staging/irda/drivers/w83977af_ir.h
diff --git a/drivers/staging/irda/net/Kconfig b/drivers/staging/irda/net/Kconfig
index cd775e1ea0e9..6abeae6c666a 100644
--- a/drivers/staging/irda/net/Kconfig
+++ b/drivers/staging/irda/net/Kconfig
@@ -92,5 +92,5 @@ config IRDA_DEBUG
 
 	  If unsure, say Y (since it makes it easier to find the bugs).
 
-source "drivers/net/irda/Kconfig"
+source "drivers/staging/irda/drivers/Kconfig"
 
-- 
2.14.1
