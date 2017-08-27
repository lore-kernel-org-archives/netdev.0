From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 1/4] irda: move net/irda/ to drivers/staging/irda/net/
Date: Sun, 27 Aug 2017 17:03:31 +0200
Message-ID: <20170827150334.32495-2-gregkh@linuxfoundation.org>
References: <20170827150334.32495-1-gregkh@linuxfoundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: davem@davemloft.net,
	samuel@sortiz.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20170827150334.32495-1-gregkh@linuxfoundation.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

It's time to get rid of IRDA.  It's long been broken, and no one seems
to use it anymore.  So move it to staging and after a while, we can
delete it from there.

To start, move the network irda core from net/irda to
drivers/staging/irda/net/

Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 drivers/staging/Kconfig                                             | 2 ++
 drivers/staging/Makefile                                            | 1 +
 {net/irda => drivers/staging/irda/net}/Kconfig                      | 6 +++---
 {net/irda => drivers/staging/irda/net}/Makefile                     | 0
 {net/irda => drivers/staging/irda/net}/af_irda.c                    | 0
 {net/irda => drivers/staging/irda/net}/discovery.c                  | 0
 {net/irda => drivers/staging/irda/net}/ircomm/Kconfig               | 0
 {net/irda => drivers/staging/irda/net}/ircomm/Makefile              | 0
 {net/irda => drivers/staging/irda/net}/ircomm/ircomm_core.c         | 0
 {net/irda => drivers/staging/irda/net}/ircomm/ircomm_event.c        | 0
 {net/irda => drivers/staging/irda/net}/ircomm/ircomm_lmp.c          | 0
 {net/irda => drivers/staging/irda/net}/ircomm/ircomm_param.c        | 0
 {net/irda => drivers/staging/irda/net}/ircomm/ircomm_ttp.c          | 0
 {net/irda => drivers/staging/irda/net}/ircomm/ircomm_tty.c          | 0
 {net/irda => drivers/staging/irda/net}/ircomm/ircomm_tty_attach.c   | 0
 {net/irda => drivers/staging/irda/net}/ircomm/ircomm_tty_ioctl.c    | 0
 {net/irda => drivers/staging/irda/net}/irda_device.c                | 0
 {net/irda => drivers/staging/irda/net}/iriap.c                      | 0
 {net/irda => drivers/staging/irda/net}/iriap_event.c                | 0
 {net/irda => drivers/staging/irda/net}/irias_object.c               | 0
 {net/irda => drivers/staging/irda/net}/irlan/Kconfig                | 0
 {net/irda => drivers/staging/irda/net}/irlan/Makefile               | 0
 {net/irda => drivers/staging/irda/net}/irlan/irlan_client.c         | 0
 {net/irda => drivers/staging/irda/net}/irlan/irlan_client_event.c   | 0
 {net/irda => drivers/staging/irda/net}/irlan/irlan_common.c         | 0
 {net/irda => drivers/staging/irda/net}/irlan/irlan_eth.c            | 0
 {net/irda => drivers/staging/irda/net}/irlan/irlan_event.c          | 0
 {net/irda => drivers/staging/irda/net}/irlan/irlan_filter.c         | 0
 {net/irda => drivers/staging/irda/net}/irlan/irlan_provider.c       | 0
 {net/irda => drivers/staging/irda/net}/irlan/irlan_provider_event.c | 0
 {net/irda => drivers/staging/irda/net}/irlap.c                      | 0
 {net/irda => drivers/staging/irda/net}/irlap_event.c                | 0
 {net/irda => drivers/staging/irda/net}/irlap_frame.c                | 0
 {net/irda => drivers/staging/irda/net}/irlmp.c                      | 0
 {net/irda => drivers/staging/irda/net}/irlmp_event.c                | 0
 {net/irda => drivers/staging/irda/net}/irlmp_frame.c                | 0
 {net/irda => drivers/staging/irda/net}/irmod.c                      | 0
 {net/irda => drivers/staging/irda/net}/irnet/Kconfig                | 0
 {net/irda => drivers/staging/irda/net}/irnet/Makefile               | 0
 {net/irda => drivers/staging/irda/net}/irnet/irnet.h                | 0
 {net/irda => drivers/staging/irda/net}/irnet/irnet_irda.c           | 0
 {net/irda => drivers/staging/irda/net}/irnet/irnet_irda.h           | 0
 {net/irda => drivers/staging/irda/net}/irnet/irnet_ppp.c            | 0
 {net/irda => drivers/staging/irda/net}/irnet/irnet_ppp.h            | 0
 {net/irda => drivers/staging/irda/net}/irnetlink.c                  | 0
 {net/irda => drivers/staging/irda/net}/irproc.c                     | 0
 {net/irda => drivers/staging/irda/net}/irqueue.c                    | 0
 {net/irda => drivers/staging/irda/net}/irsysctl.c                   | 0
 {net/irda => drivers/staging/irda/net}/irttp.c                      | 0
 {net/irda => drivers/staging/irda/net}/parameters.c                 | 0
 {net/irda => drivers/staging/irda/net}/qos.c                        | 0
 {net/irda => drivers/staging/irda/net}/timer.c                      | 0
 {net/irda => drivers/staging/irda/net}/wrapper.c                    | 0
 net/Kconfig                                                         | 1 -
 net/Makefile                                                        | 1 -
 55 files changed, 6 insertions(+), 5 deletions(-)
 rename {net/irda => drivers/staging/irda/net}/Kconfig (95%)
 rename {net/irda => drivers/staging/irda/net}/Makefile (100%)
 rename {net/irda => drivers/staging/irda/net}/af_irda.c (100%)
 rename {net/irda => drivers/staging/irda/net}/discovery.c (100%)
 rename {net/irda => drivers/staging/irda/net}/ircomm/Kconfig (100%)
 rename {net/irda => drivers/staging/irda/net}/ircomm/Makefile (100%)
 rename {net/irda => drivers/staging/irda/net}/ircomm/ircomm_core.c (100%)
 rename {net/irda => drivers/staging/irda/net}/ircomm/ircomm_event.c (100%)
 rename {net/irda => drivers/staging/irda/net}/ircomm/ircomm_lmp.c (100%)
 rename {net/irda => drivers/staging/irda/net}/ircomm/ircomm_param.c (100%)
 rename {net/irda => drivers/staging/irda/net}/ircomm/ircomm_ttp.c (100%)
 rename {net/irda => drivers/staging/irda/net}/ircomm/ircomm_tty.c (100%)
 rename {net/irda => drivers/staging/irda/net}/ircomm/ircomm_tty_attach.c (100%)
 rename {net/irda => drivers/staging/irda/net}/ircomm/ircomm_tty_ioctl.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irda_device.c (100%)
 rename {net/irda => drivers/staging/irda/net}/iriap.c (100%)
 rename {net/irda => drivers/staging/irda/net}/iriap_event.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irias_object.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irlan/Kconfig (100%)
 rename {net/irda => drivers/staging/irda/net}/irlan/Makefile (100%)
 rename {net/irda => drivers/staging/irda/net}/irlan/irlan_client.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irlan/irlan_client_event.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irlan/irlan_common.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irlan/irlan_eth.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irlan/irlan_event.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irlan/irlan_filter.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irlan/irlan_provider.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irlan/irlan_provider_event.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irlap.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irlap_event.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irlap_frame.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irlmp.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irlmp_event.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irlmp_frame.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irmod.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irnet/Kconfig (100%)
 rename {net/irda => drivers/staging/irda/net}/irnet/Makefile (100%)
 rename {net/irda => drivers/staging/irda/net}/irnet/irnet.h (100%)
 rename {net/irda => drivers/staging/irda/net}/irnet/irnet_irda.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irnet/irnet_irda.h (100%)
 rename {net/irda => drivers/staging/irda/net}/irnet/irnet_ppp.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irnet/irnet_ppp.h (100%)
 rename {net/irda => drivers/staging/irda/net}/irnetlink.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irproc.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irqueue.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irsysctl.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irttp.c (100%)
 rename {net/irda => drivers/staging/irda/net}/parameters.c (100%)
 rename {net/irda => drivers/staging/irda/net}/qos.c (100%)
 rename {net/irda => drivers/staging/irda/net}/timer.c (100%)
 rename {net/irda => drivers/staging/irda/net}/wrapper.c (100%)

diff --git a/drivers/staging/Kconfig b/drivers/staging/Kconfig
index ef28a1cb64ae..0c5086d878c6 100644
--- a/drivers/staging/Kconfig
+++ b/drivers/staging/Kconfig
@@ -24,6 +24,8 @@ menuconfig STAGING
 
 if STAGING
 
+source "drivers/staging/irda/net/Kconfig"
+
 source "drivers/staging/wlan-ng/Kconfig"
 
 source "drivers/staging/comedi/Kconfig"
diff --git a/drivers/staging/Makefile b/drivers/staging/Makefile
index 2918580bdb9e..509fbacf9a7e 100644
--- a/drivers/staging/Makefile
+++ b/drivers/staging/Makefile
@@ -2,6 +2,7 @@
 
 obj-y				+= media/
 obj-y				+= typec/
+obj-$(CONFIG_IRDA)		+= irda/net/
 obj-$(CONFIG_PRISM2_USB)	+= wlan-ng/
 obj-$(CONFIG_COMEDI)		+= comedi/
 obj-$(CONFIG_FB_OLPC_DCON)	+= olpc_dcon/
diff --git a/net/irda/Kconfig b/drivers/staging/irda/net/Kconfig
similarity index 95%
rename from net/irda/Kconfig
rename to drivers/staging/irda/net/Kconfig
index c8671a7ffb3c..cd775e1ea0e9 100644
--- a/net/irda/Kconfig
+++ b/drivers/staging/irda/net/Kconfig
@@ -27,11 +27,11 @@ menuconfig IRDA
 comment "IrDA protocols"
 	depends on IRDA
 
-source "net/irda/irlan/Kconfig"
+source "drivers/staging/irda/net/irlan/Kconfig"
 
-source "net/irda/irnet/Kconfig"
+source "drivers/staging/irda/net/irnet/Kconfig"
 
-source "net/irda/ircomm/Kconfig"
+source "drivers/staging/irda/net/ircomm/Kconfig"
 
 config IRDA_ULTRA
 	bool "Ultra (connectionless) protocol"
diff --git a/net/irda/Makefile b/drivers/staging/irda/net/Makefile
similarity index 100%
rename from net/irda/Makefile
rename to drivers/staging/irda/net/Makefile
diff --git a/net/irda/af_irda.c b/drivers/staging/irda/net/af_irda.c
similarity index 100%
rename from net/irda/af_irda.c
rename to drivers/staging/irda/net/af_irda.c
diff --git a/net/irda/discovery.c b/drivers/staging/irda/net/discovery.c
similarity index 100%
rename from net/irda/discovery.c
rename to drivers/staging/irda/net/discovery.c
diff --git a/net/irda/ircomm/Kconfig b/drivers/staging/irda/net/ircomm/Kconfig
similarity index 100%
rename from net/irda/ircomm/Kconfig
rename to drivers/staging/irda/net/ircomm/Kconfig
diff --git a/net/irda/ircomm/Makefile b/drivers/staging/irda/net/ircomm/Makefile
similarity index 100%
rename from net/irda/ircomm/Makefile
rename to drivers/staging/irda/net/ircomm/Makefile
diff --git a/net/irda/ircomm/ircomm_core.c b/drivers/staging/irda/net/ircomm/ircomm_core.c
similarity index 100%
rename from net/irda/ircomm/ircomm_core.c
rename to drivers/staging/irda/net/ircomm/ircomm_core.c
diff --git a/net/irda/ircomm/ircomm_event.c b/drivers/staging/irda/net/ircomm/ircomm_event.c
similarity index 100%
rename from net/irda/ircomm/ircomm_event.c
rename to drivers/staging/irda/net/ircomm/ircomm_event.c
diff --git a/net/irda/ircomm/ircomm_lmp.c b/drivers/staging/irda/net/ircomm/ircomm_lmp.c
similarity index 100%
rename from net/irda/ircomm/ircomm_lmp.c
rename to drivers/staging/irda/net/ircomm/ircomm_lmp.c
diff --git a/net/irda/ircomm/ircomm_param.c b/drivers/staging/irda/net/ircomm/ircomm_param.c
similarity index 100%
rename from net/irda/ircomm/ircomm_param.c
rename to drivers/staging/irda/net/ircomm/ircomm_param.c
diff --git a/net/irda/ircomm/ircomm_ttp.c b/drivers/staging/irda/net/ircomm/ircomm_ttp.c
similarity index 100%
rename from net/irda/ircomm/ircomm_ttp.c
rename to drivers/staging/irda/net/ircomm/ircomm_ttp.c
diff --git a/net/irda/ircomm/ircomm_tty.c b/drivers/staging/irda/net/ircomm/ircomm_tty.c
similarity index 100%
rename from net/irda/ircomm/ircomm_tty.c
rename to drivers/staging/irda/net/ircomm/ircomm_tty.c
diff --git a/net/irda/ircomm/ircomm_tty_attach.c b/drivers/staging/irda/net/ircomm/ircomm_tty_attach.c
similarity index 100%
rename from net/irda/ircomm/ircomm_tty_attach.c
rename to drivers/staging/irda/net/ircomm/ircomm_tty_attach.c
diff --git a/net/irda/ircomm/ircomm_tty_ioctl.c b/drivers/staging/irda/net/ircomm/ircomm_tty_ioctl.c
similarity index 100%
rename from net/irda/ircomm/ircomm_tty_ioctl.c
rename to drivers/staging/irda/net/ircomm/ircomm_tty_ioctl.c
diff --git a/net/irda/irda_device.c b/drivers/staging/irda/net/irda_device.c
similarity index 100%
rename from net/irda/irda_device.c
rename to drivers/staging/irda/net/irda_device.c
diff --git a/net/irda/iriap.c b/drivers/staging/irda/net/iriap.c
similarity index 100%
rename from net/irda/iriap.c
rename to drivers/staging/irda/net/iriap.c
diff --git a/net/irda/iriap_event.c b/drivers/staging/irda/net/iriap_event.c
similarity index 100%
rename from net/irda/iriap_event.c
rename to drivers/staging/irda/net/iriap_event.c
diff --git a/net/irda/irias_object.c b/drivers/staging/irda/net/irias_object.c
similarity index 100%
rename from net/irda/irias_object.c
rename to drivers/staging/irda/net/irias_object.c
diff --git a/net/irda/irlan/Kconfig b/drivers/staging/irda/net/irlan/Kconfig
similarity index 100%
rename from net/irda/irlan/Kconfig
rename to drivers/staging/irda/net/irlan/Kconfig
diff --git a/net/irda/irlan/Makefile b/drivers/staging/irda/net/irlan/Makefile
similarity index 100%
rename from net/irda/irlan/Makefile
rename to drivers/staging/irda/net/irlan/Makefile
diff --git a/net/irda/irlan/irlan_client.c b/drivers/staging/irda/net/irlan/irlan_client.c
similarity index 100%
rename from net/irda/irlan/irlan_client.c
rename to drivers/staging/irda/net/irlan/irlan_client.c
diff --git a/net/irda/irlan/irlan_client_event.c b/drivers/staging/irda/net/irlan/irlan_client_event.c
similarity index 100%
rename from net/irda/irlan/irlan_client_event.c
rename to drivers/staging/irda/net/irlan/irlan_client_event.c
diff --git a/net/irda/irlan/irlan_common.c b/drivers/staging/irda/net/irlan/irlan_common.c
similarity index 100%
rename from net/irda/irlan/irlan_common.c
rename to drivers/staging/irda/net/irlan/irlan_common.c
diff --git a/net/irda/irlan/irlan_eth.c b/drivers/staging/irda/net/irlan/irlan_eth.c
similarity index 100%
rename from net/irda/irlan/irlan_eth.c
rename to drivers/staging/irda/net/irlan/irlan_eth.c
diff --git a/net/irda/irlan/irlan_event.c b/drivers/staging/irda/net/irlan/irlan_event.c
similarity index 100%
rename from net/irda/irlan/irlan_event.c
rename to drivers/staging/irda/net/irlan/irlan_event.c
diff --git a/net/irda/irlan/irlan_filter.c b/drivers/staging/irda/net/irlan/irlan_filter.c
similarity index 100%
rename from net/irda/irlan/irlan_filter.c
rename to drivers/staging/irda/net/irlan/irlan_filter.c
diff --git a/net/irda/irlan/irlan_provider.c b/drivers/staging/irda/net/irlan/irlan_provider.c
similarity index 100%
rename from net/irda/irlan/irlan_provider.c
rename to drivers/staging/irda/net/irlan/irlan_provider.c
diff --git a/net/irda/irlan/irlan_provider_event.c b/drivers/staging/irda/net/irlan/irlan_provider_event.c
similarity index 100%
rename from net/irda/irlan/irlan_provider_event.c
rename to drivers/staging/irda/net/irlan/irlan_provider_event.c
diff --git a/net/irda/irlap.c b/drivers/staging/irda/net/irlap.c
similarity index 100%
rename from net/irda/irlap.c
rename to drivers/staging/irda/net/irlap.c
diff --git a/net/irda/irlap_event.c b/drivers/staging/irda/net/irlap_event.c
similarity index 100%
rename from net/irda/irlap_event.c
rename to drivers/staging/irda/net/irlap_event.c
diff --git a/net/irda/irlap_frame.c b/drivers/staging/irda/net/irlap_frame.c
similarity index 100%
rename from net/irda/irlap_frame.c
rename to drivers/staging/irda/net/irlap_frame.c
diff --git a/net/irda/irlmp.c b/drivers/staging/irda/net/irlmp.c
similarity index 100%
rename from net/irda/irlmp.c
rename to drivers/staging/irda/net/irlmp.c
diff --git a/net/irda/irlmp_event.c b/drivers/staging/irda/net/irlmp_event.c
similarity index 100%
rename from net/irda/irlmp_event.c
rename to drivers/staging/irda/net/irlmp_event.c
diff --git a/net/irda/irlmp_frame.c b/drivers/staging/irda/net/irlmp_frame.c
similarity index 100%
rename from net/irda/irlmp_frame.c
rename to drivers/staging/irda/net/irlmp_frame.c
diff --git a/net/irda/irmod.c b/drivers/staging/irda/net/irmod.c
similarity index 100%
rename from net/irda/irmod.c
rename to drivers/staging/irda/net/irmod.c
diff --git a/net/irda/irnet/Kconfig b/drivers/staging/irda/net/irnet/Kconfig
similarity index 100%
rename from net/irda/irnet/Kconfig
rename to drivers/staging/irda/net/irnet/Kconfig
diff --git a/net/irda/irnet/Makefile b/drivers/staging/irda/net/irnet/Makefile
similarity index 100%
rename from net/irda/irnet/Makefile
rename to drivers/staging/irda/net/irnet/Makefile
diff --git a/net/irda/irnet/irnet.h b/drivers/staging/irda/net/irnet/irnet.h
similarity index 100%
rename from net/irda/irnet/irnet.h
rename to drivers/staging/irda/net/irnet/irnet.h
diff --git a/net/irda/irnet/irnet_irda.c b/drivers/staging/irda/net/irnet/irnet_irda.c
similarity index 100%
rename from net/irda/irnet/irnet_irda.c
rename to drivers/staging/irda/net/irnet/irnet_irda.c
diff --git a/net/irda/irnet/irnet_irda.h b/drivers/staging/irda/net/irnet/irnet_irda.h
similarity index 100%
rename from net/irda/irnet/irnet_irda.h
rename to drivers/staging/irda/net/irnet/irnet_irda.h
diff --git a/net/irda/irnet/irnet_ppp.c b/drivers/staging/irda/net/irnet/irnet_ppp.c
similarity index 100%
rename from net/irda/irnet/irnet_ppp.c
rename to drivers/staging/irda/net/irnet/irnet_ppp.c
diff --git a/net/irda/irnet/irnet_ppp.h b/drivers/staging/irda/net/irnet/irnet_ppp.h
similarity index 100%
rename from net/irda/irnet/irnet_ppp.h
rename to drivers/staging/irda/net/irnet/irnet_ppp.h
diff --git a/net/irda/irnetlink.c b/drivers/staging/irda/net/irnetlink.c
similarity index 100%
rename from net/irda/irnetlink.c
rename to drivers/staging/irda/net/irnetlink.c
diff --git a/net/irda/irproc.c b/drivers/staging/irda/net/irproc.c
similarity index 100%
rename from net/irda/irproc.c
rename to drivers/staging/irda/net/irproc.c
diff --git a/net/irda/irqueue.c b/drivers/staging/irda/net/irqueue.c
similarity index 100%
rename from net/irda/irqueue.c
rename to drivers/staging/irda/net/irqueue.c
diff --git a/net/irda/irsysctl.c b/drivers/staging/irda/net/irsysctl.c
similarity index 100%
rename from net/irda/irsysctl.c
rename to drivers/staging/irda/net/irsysctl.c
diff --git a/net/irda/irttp.c b/drivers/staging/irda/net/irttp.c
similarity index 100%
rename from net/irda/irttp.c
rename to drivers/staging/irda/net/irttp.c
diff --git a/net/irda/parameters.c b/drivers/staging/irda/net/parameters.c
similarity index 100%
rename from net/irda/parameters.c
rename to drivers/staging/irda/net/parameters.c
diff --git a/net/irda/qos.c b/drivers/staging/irda/net/qos.c
similarity index 100%
rename from net/irda/qos.c
rename to drivers/staging/irda/net/qos.c
diff --git a/net/irda/timer.c b/drivers/staging/irda/net/timer.c
similarity index 100%
rename from net/irda/timer.c
rename to drivers/staging/irda/net/timer.c
diff --git a/net/irda/wrapper.c b/drivers/staging/irda/net/wrapper.c
similarity index 100%
rename from net/irda/wrapper.c
rename to drivers/staging/irda/net/wrapper.c
diff --git a/net/Kconfig b/net/Kconfig
index 7d57ef34b79c..992a5b8f72d7 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -364,7 +364,6 @@ endmenu
 
 source "net/ax25/Kconfig"
 source "net/can/Kconfig"
-source "net/irda/Kconfig"
 source "net/bluetooth/Kconfig"
 source "net/rxrpc/Kconfig"
 source "net/kcm/Kconfig"
diff --git a/net/Makefile b/net/Makefile
index bed80fa398b7..3d3feff3643b 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -31,7 +31,6 @@ obj-$(CONFIG_NETROM)		+= netrom/
 obj-$(CONFIG_ROSE)		+= rose/
 obj-$(CONFIG_AX25)		+= ax25/
 obj-$(CONFIG_CAN)		+= can/
-obj-$(CONFIG_IRDA)		+= irda/
 obj-$(CONFIG_BT)		+= bluetooth/
 obj-$(CONFIG_SUNRPC)		+= sunrpc/
 obj-$(CONFIG_AF_RXRPC)		+= rxrpc/
-- 
2.14.1
