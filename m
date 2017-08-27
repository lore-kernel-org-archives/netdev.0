From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 3/4] irda: move include/net/irda into staging subdirectory
Date: Sun, 27 Aug 2017 17:03:33 +0200
Message-ID: <20170827150334.32495-4-gregkh@linuxfoundation.org>
References: <20170827150334.32495-1-gregkh@linuxfoundation.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        devel@driverdev.osuosl.org,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: davem@davemloft.net, samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:50306 "EHLO
        mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751255AbdH0PDw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Aug 2017 11:03:52 -0400
In-Reply-To: <20170827150334.32495-1-gregkh@linuxfoundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

And finally, move the irda include files into
drivers/staging/irda/include/net/irda.  Yes, it's a long path, but it
makes it easy for us to just add a Makefile directory path addition and
all of the net and drivers code "just works".

Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 drivers/staging/irda/drivers/Makefile                                  | 2 ++
 {include => drivers/staging/irda/include}/net/irda/af_irda.h           | 0
 {include => drivers/staging/irda/include}/net/irda/crc.h               | 0
 {include => drivers/staging/irda/include}/net/irda/discovery.h         | 0
 {include => drivers/staging/irda/include}/net/irda/ircomm_core.h       | 0
 {include => drivers/staging/irda/include}/net/irda/ircomm_event.h      | 0
 {include => drivers/staging/irda/include}/net/irda/ircomm_lmp.h        | 0
 {include => drivers/staging/irda/include}/net/irda/ircomm_param.h      | 0
 {include => drivers/staging/irda/include}/net/irda/ircomm_ttp.h        | 0
 {include => drivers/staging/irda/include}/net/irda/ircomm_tty.h        | 0
 {include => drivers/staging/irda/include}/net/irda/ircomm_tty_attach.h | 0
 {include => drivers/staging/irda/include}/net/irda/irda.h              | 0
 {include => drivers/staging/irda/include}/net/irda/irda_device.h       | 0
 {include => drivers/staging/irda/include}/net/irda/iriap.h             | 0
 {include => drivers/staging/irda/include}/net/irda/iriap_event.h       | 0
 {include => drivers/staging/irda/include}/net/irda/irias_object.h      | 0
 {include => drivers/staging/irda/include}/net/irda/irlan_client.h      | 0
 {include => drivers/staging/irda/include}/net/irda/irlan_common.h      | 0
 {include => drivers/staging/irda/include}/net/irda/irlan_eth.h         | 0
 {include => drivers/staging/irda/include}/net/irda/irlan_event.h       | 0
 {include => drivers/staging/irda/include}/net/irda/irlan_filter.h      | 0
 {include => drivers/staging/irda/include}/net/irda/irlan_provider.h    | 0
 {include => drivers/staging/irda/include}/net/irda/irlap.h             | 0
 {include => drivers/staging/irda/include}/net/irda/irlap_event.h       | 0
 {include => drivers/staging/irda/include}/net/irda/irlap_frame.h       | 0
 {include => drivers/staging/irda/include}/net/irda/irlmp.h             | 0
 {include => drivers/staging/irda/include}/net/irda/irlmp_event.h       | 0
 {include => drivers/staging/irda/include}/net/irda/irlmp_frame.h       | 0
 {include => drivers/staging/irda/include}/net/irda/irmod.h             | 0
 {include => drivers/staging/irda/include}/net/irda/irqueue.h           | 0
 {include => drivers/staging/irda/include}/net/irda/irttp.h             | 0
 {include => drivers/staging/irda/include}/net/irda/parameters.h        | 0
 {include => drivers/staging/irda/include}/net/irda/qos.h               | 0
 {include => drivers/staging/irda/include}/net/irda/timer.h             | 0
 {include => drivers/staging/irda/include}/net/irda/wrapper.h           | 0
 drivers/staging/irda/net/Makefile                                      | 2 ++
 36 files changed, 4 insertions(+)
 rename {include => drivers/staging/irda/include}/net/irda/af_irda.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/crc.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/discovery.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/ircomm_core.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/ircomm_event.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/ircomm_lmp.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/ircomm_param.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/ircomm_ttp.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/ircomm_tty.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/ircomm_tty_attach.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/irda.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/irda_device.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/iriap.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/iriap_event.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/irias_object.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/irlan_client.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/irlan_common.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/irlan_eth.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/irlan_event.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/irlan_filter.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/irlan_provider.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/irlap.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/irlap_event.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/irlap_frame.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/irlmp.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/irlmp_event.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/irlmp_frame.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/irmod.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/irqueue.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/irttp.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/parameters.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/qos.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/timer.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/wrapper.h (100%)

diff --git a/drivers/staging/irda/drivers/Makefile b/drivers/staging/irda/drivers/Makefile
index 4c344433dae5..e2901b135528 100644
--- a/drivers/staging/irda/drivers/Makefile
+++ b/drivers/staging/irda/drivers/Makefile
@@ -5,6 +5,8 @@
 # Rewritten to use lists instead of if-statements.
 #
 
+subdir-ccflags-y += -I$(srctree)/drivers/staging/irda/include
+
 # FIR drivers
 obj-$(CONFIG_USB_IRDA)		+= irda-usb.o
 obj-$(CONFIG_SIGMATEL_FIR)	+= stir4200.o
diff --git a/include/net/irda/af_irda.h b/drivers/staging/irda/include/net/irda/af_irda.h
similarity index 100%
rename from include/net/irda/af_irda.h
rename to drivers/staging/irda/include/net/irda/af_irda.h
diff --git a/include/net/irda/crc.h b/drivers/staging/irda/include/net/irda/crc.h
similarity index 100%
rename from include/net/irda/crc.h
rename to drivers/staging/irda/include/net/irda/crc.h
diff --git a/include/net/irda/discovery.h b/drivers/staging/irda/include/net/irda/discovery.h
similarity index 100%
rename from include/net/irda/discovery.h
rename to drivers/staging/irda/include/net/irda/discovery.h
diff --git a/include/net/irda/ircomm_core.h b/drivers/staging/irda/include/net/irda/ircomm_core.h
similarity index 100%
rename from include/net/irda/ircomm_core.h
rename to drivers/staging/irda/include/net/irda/ircomm_core.h
diff --git a/include/net/irda/ircomm_event.h b/drivers/staging/irda/include/net/irda/ircomm_event.h
similarity index 100%
rename from include/net/irda/ircomm_event.h
rename to drivers/staging/irda/include/net/irda/ircomm_event.h
diff --git a/include/net/irda/ircomm_lmp.h b/drivers/staging/irda/include/net/irda/ircomm_lmp.h
similarity index 100%
rename from include/net/irda/ircomm_lmp.h
rename to drivers/staging/irda/include/net/irda/ircomm_lmp.h
diff --git a/include/net/irda/ircomm_param.h b/drivers/staging/irda/include/net/irda/ircomm_param.h
similarity index 100%
rename from include/net/irda/ircomm_param.h
rename to drivers/staging/irda/include/net/irda/ircomm_param.h
diff --git a/include/net/irda/ircomm_ttp.h b/drivers/staging/irda/include/net/irda/ircomm_ttp.h
similarity index 100%
rename from include/net/irda/ircomm_ttp.h
rename to drivers/staging/irda/include/net/irda/ircomm_ttp.h
diff --git a/include/net/irda/ircomm_tty.h b/drivers/staging/irda/include/net/irda/ircomm_tty.h
similarity index 100%
rename from include/net/irda/ircomm_tty.h
rename to drivers/staging/irda/include/net/irda/ircomm_tty.h
diff --git a/include/net/irda/ircomm_tty_attach.h b/drivers/staging/irda/include/net/irda/ircomm_tty_attach.h
similarity index 100%
rename from include/net/irda/ircomm_tty_attach.h
rename to drivers/staging/irda/include/net/irda/ircomm_tty_attach.h
diff --git a/include/net/irda/irda.h b/drivers/staging/irda/include/net/irda/irda.h
similarity index 100%
rename from include/net/irda/irda.h
rename to drivers/staging/irda/include/net/irda/irda.h
diff --git a/include/net/irda/irda_device.h b/drivers/staging/irda/include/net/irda/irda_device.h
similarity index 100%
rename from include/net/irda/irda_device.h
rename to drivers/staging/irda/include/net/irda/irda_device.h
diff --git a/include/net/irda/iriap.h b/drivers/staging/irda/include/net/irda/iriap.h
similarity index 100%
rename from include/net/irda/iriap.h
rename to drivers/staging/irda/include/net/irda/iriap.h
diff --git a/include/net/irda/iriap_event.h b/drivers/staging/irda/include/net/irda/iriap_event.h
similarity index 100%
rename from include/net/irda/iriap_event.h
rename to drivers/staging/irda/include/net/irda/iriap_event.h
diff --git a/include/net/irda/irias_object.h b/drivers/staging/irda/include/net/irda/irias_object.h
similarity index 100%
rename from include/net/irda/irias_object.h
rename to drivers/staging/irda/include/net/irda/irias_object.h
diff --git a/include/net/irda/irlan_client.h b/drivers/staging/irda/include/net/irda/irlan_client.h
similarity index 100%
rename from include/net/irda/irlan_client.h
rename to drivers/staging/irda/include/net/irda/irlan_client.h
diff --git a/include/net/irda/irlan_common.h b/drivers/staging/irda/include/net/irda/irlan_common.h
similarity index 100%
rename from include/net/irda/irlan_common.h
rename to drivers/staging/irda/include/net/irda/irlan_common.h
diff --git a/include/net/irda/irlan_eth.h b/drivers/staging/irda/include/net/irda/irlan_eth.h
similarity index 100%
rename from include/net/irda/irlan_eth.h
rename to drivers/staging/irda/include/net/irda/irlan_eth.h
diff --git a/include/net/irda/irlan_event.h b/drivers/staging/irda/include/net/irda/irlan_event.h
similarity index 100%
rename from include/net/irda/irlan_event.h
rename to drivers/staging/irda/include/net/irda/irlan_event.h
diff --git a/include/net/irda/irlan_filter.h b/drivers/staging/irda/include/net/irda/irlan_filter.h
similarity index 100%
rename from include/net/irda/irlan_filter.h
rename to drivers/staging/irda/include/net/irda/irlan_filter.h
diff --git a/include/net/irda/irlan_provider.h b/drivers/staging/irda/include/net/irda/irlan_provider.h
similarity index 100%
rename from include/net/irda/irlan_provider.h
rename to drivers/staging/irda/include/net/irda/irlan_provider.h
diff --git a/include/net/irda/irlap.h b/drivers/staging/irda/include/net/irda/irlap.h
similarity index 100%
rename from include/net/irda/irlap.h
rename to drivers/staging/irda/include/net/irda/irlap.h
diff --git a/include/net/irda/irlap_event.h b/drivers/staging/irda/include/net/irda/irlap_event.h
similarity index 100%
rename from include/net/irda/irlap_event.h
rename to drivers/staging/irda/include/net/irda/irlap_event.h
diff --git a/include/net/irda/irlap_frame.h b/drivers/staging/irda/include/net/irda/irlap_frame.h
similarity index 100%
rename from include/net/irda/irlap_frame.h
rename to drivers/staging/irda/include/net/irda/irlap_frame.h
diff --git a/include/net/irda/irlmp.h b/drivers/staging/irda/include/net/irda/irlmp.h
similarity index 100%
rename from include/net/irda/irlmp.h
rename to drivers/staging/irda/include/net/irda/irlmp.h
diff --git a/include/net/irda/irlmp_event.h b/drivers/staging/irda/include/net/irda/irlmp_event.h
similarity index 100%
rename from include/net/irda/irlmp_event.h
rename to drivers/staging/irda/include/net/irda/irlmp_event.h
diff --git a/include/net/irda/irlmp_frame.h b/drivers/staging/irda/include/net/irda/irlmp_frame.h
similarity index 100%
rename from include/net/irda/irlmp_frame.h
rename to drivers/staging/irda/include/net/irda/irlmp_frame.h
diff --git a/include/net/irda/irmod.h b/drivers/staging/irda/include/net/irda/irmod.h
similarity index 100%
rename from include/net/irda/irmod.h
rename to drivers/staging/irda/include/net/irda/irmod.h
diff --git a/include/net/irda/irqueue.h b/drivers/staging/irda/include/net/irda/irqueue.h
similarity index 100%
rename from include/net/irda/irqueue.h
rename to drivers/staging/irda/include/net/irda/irqueue.h
diff --git a/include/net/irda/irttp.h b/drivers/staging/irda/include/net/irda/irttp.h
similarity index 100%
rename from include/net/irda/irttp.h
rename to drivers/staging/irda/include/net/irda/irttp.h
diff --git a/include/net/irda/parameters.h b/drivers/staging/irda/include/net/irda/parameters.h
similarity index 100%
rename from include/net/irda/parameters.h
rename to drivers/staging/irda/include/net/irda/parameters.h
diff --git a/include/net/irda/qos.h b/drivers/staging/irda/include/net/irda/qos.h
similarity index 100%
rename from include/net/irda/qos.h
rename to drivers/staging/irda/include/net/irda/qos.h
diff --git a/include/net/irda/timer.h b/drivers/staging/irda/include/net/irda/timer.h
similarity index 100%
rename from include/net/irda/timer.h
rename to drivers/staging/irda/include/net/irda/timer.h
diff --git a/include/net/irda/wrapper.h b/drivers/staging/irda/include/net/irda/wrapper.h
similarity index 100%
rename from include/net/irda/wrapper.h
rename to drivers/staging/irda/include/net/irda/wrapper.h
diff --git a/drivers/staging/irda/net/Makefile b/drivers/staging/irda/net/Makefile
index 187f6c563a4b..bd1a635b88cf 100644
--- a/drivers/staging/irda/net/Makefile
+++ b/drivers/staging/irda/net/Makefile
@@ -2,6 +2,8 @@
 # Makefile for the Linux IrDA protocol layer.
 #
 
+subdir-ccflags-y += -I$(srctree)/drivers/staging/irda/include
+
 obj-$(CONFIG_IRDA) += irda.o
 obj-$(CONFIG_IRLAN) += irlan/
 obj-$(CONFIG_IRNET) += irnet/
-- 
2.14.1
