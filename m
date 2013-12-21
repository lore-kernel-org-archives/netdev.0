From: Ravi Patel <rapatel-qTEPVZfXA3Y@public.gmane.org>
Subject: [PATCH V2 0/4] misc: xgene: Add support for APM X-Gene SoC Queue Manager/Traffic Manager
Date: Fri, 20 Dec 2013 18:57:27 -0800
Message-ID: <1387594651-25771-1-git-send-email-rapatel@apm.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	jcm-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, patches-qTEPVZfXA3Y@public.gmane.org, Ravi Patel <rapatel-qTEPVZfXA3Y@public.gmane.org>,
	Keyur Chudgar <kchudgar-qTEPVZfXA3Y@public.gmane.org>
To: arnd-r2nGTMty4D4@public.gmane.org, gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch adds support for APM X-Gene SoC Queue Manager/Traffic Manager.
 QMTM is required by APM X-Gene SoC Ethernet, PktDMA (XOR Engine) and
 Security Engine subsystems. All subsystems communicate with QMTM using
 messages which include information about the work to be performed and
 the location of associated data buffers.  

V2:
 * Adding COMPILE_TEST dependency for QMTM in Kconfig
 * Updated license banner as per review comments
 * Fixed alignment for macros
 * Changed EXPORT_SYMBOL to EXPORT_SYMBOL_GPL

V1:
 * inital version

Signed-off-by: Ravi Patel <rapatel-qTEPVZfXA3Y@public.gmane.org>
Signed-off-by: Keyur Chudgar <kchudgar-qTEPVZfXA3Y@public.gmane.org>
---
Ravi Patel (4):
  Documentation: Add documentation for APM X-Gene SoC Queue
    Manager/Traffic Manager DTS binding
  misc: xgene: Add base driver for APM X-Gene SoC Queue Manager/Traffic
    Manager
  arm64: boot: dts: Add DTS entries for APM X-Gene SoC Queue
    Manager/Traffic Manager
  misc: xgene: Add error handling for APM X-Gene SoC Queue
    Manager/Traffic Manager

 .../devicetree/bindings/misc/apm-xgene-qmtm.txt    |   51 ++
 MAINTAINERS                                        |    7 +
 arch/arm64/boot/dts/apm-storm.dtsi                 |   17 +
 drivers/misc/Kconfig                               |    1 +
 drivers/misc/Makefile                              |    1 +
 drivers/misc/xgene/Kconfig                         |    1 +
 drivers/misc/xgene/Makefile                        |    5 +
 drivers/misc/xgene/qmtm/Kconfig                    |    9 +
 drivers/misc/xgene/qmtm/Makefile                   |    7 +
 drivers/misc/xgene/qmtm/xgene_qmtm_error.c         |  283 ++++++++
 drivers/misc/xgene/qmtm/xgene_qmtm_main.c          |  765 ++++++++++++++++++++
 drivers/misc/xgene/qmtm/xgene_qmtm_main.h          |  138 ++++
 drivers/misc/xgene/qmtm/xgene_qmtm_storm.c         |  370 ++++++++++
 drivers/misc/xgene/qmtm/xgene_qmtm_storm.h         |  139 ++++
 include/misc/xgene/xgene_qmtm.h                    |  277 +++++++
 15 files changed, 2071 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/misc/apm-xgene-qmtm.txt
 create mode 100644 drivers/misc/xgene/Kconfig
 create mode 100644 drivers/misc/xgene/Makefile
 create mode 100644 drivers/misc/xgene/qmtm/Kconfig
 create mode 100644 drivers/misc/xgene/qmtm/Makefile
 create mode 100644 drivers/misc/xgene/qmtm/xgene_qmtm_error.c
 create mode 100644 drivers/misc/xgene/qmtm/xgene_qmtm_main.c
 create mode 100644 drivers/misc/xgene/qmtm/xgene_qmtm_main.h
 create mode 100644 drivers/misc/xgene/qmtm/xgene_qmtm_storm.c
 create mode 100644 drivers/misc/xgene/qmtm/xgene_qmtm_storm.h
 create mode 100644 include/misc/xgene/xgene_qmtm.h

-- 
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
