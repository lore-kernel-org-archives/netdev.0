From: Jassi Brar <jassisinghbrar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [net-next PATCHv6 0/2] net: ethernet: Socionext Netsec
Date: Wed, 30 Aug 2017 15:54:17 +0530
Message-ID: <1504088657-6102-1-git-send-email-jaswinder.singh@linaro.org>
Cc: patches-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
        robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, andy-/Zus8d0mwwtBDgjK7y7TUQ@public.gmane.org,
        Jassi Brar <jaswinder.singh-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello,

  The OGMA/Netsec controller is used in latest SoC from Socionext/Fujitsu.

I am refreshing the patchset by basically using official name of the IP
from 'OGMA' to 'Netsec'. And the company is renamed too, from Fujitsu
to Socionext to better reflect the reality.

 I have addressed comments (that could be) on the last revision -->
https://patchwork.kernel.org/patch/4540651/

 Of course, I have scanned changes to the drivers/net/ethernet since
last submission and integrated whichever applicable and rebased the
driver on top of last rc.

Thanks.

Jassi Brar (2):
  dt-bindings: net: Add DT bindings for Socionext Netsec
  net: socionext: Add NetSec driver

 .../devicetree/bindings/net/socionext-netsec.txt   |  46 ++
 drivers/net/ethernet/Kconfig                       |   1 +
 drivers/net/ethernet/Makefile                      |   1 +
 drivers/net/ethernet/socionext/Kconfig             |  29 +
 drivers/net/ethernet/socionext/Makefile            |   1 +
 drivers/net/ethernet/socionext/netsec/Makefile     |   6 +
 drivers/net/ethernet/socionext/netsec/netsec.h     | 386 +++++++++++++
 .../socionext/netsec/netsec_desc_ring_access.c     | 618 +++++++++++++++++++++
 .../net/ethernet/socionext/netsec/netsec_ethtool.c |  76 +++
 .../ethernet/socionext/netsec/netsec_gmac_access.c | 329 +++++++++++
 .../net/ethernet/socionext/netsec/netsec_netdev.c  | 558 +++++++++++++++++++
 .../ethernet/socionext/netsec/netsec_platform.c    | 330 +++++++++++
 12 files changed, 2381 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/socionext-netsec.txt
 create mode 100644 drivers/net/ethernet/socionext/Kconfig
 create mode 100644 drivers/net/ethernet/socionext/Makefile
 create mode 100644 drivers/net/ethernet/socionext/netsec/Makefile
 create mode 100644 drivers/net/ethernet/socionext/netsec/netsec.h
 create mode 100644 drivers/net/ethernet/socionext/netsec/netsec_desc_ring_access.c
 create mode 100644 drivers/net/ethernet/socionext/netsec/netsec_ethtool.c
 create mode 100644 drivers/net/ethernet/socionext/netsec/netsec_gmac_access.c
 create mode 100644 drivers/net/ethernet/socionext/netsec/netsec_netdev.c
 create mode 100644 drivers/net/ethernet/socionext/netsec/netsec_platform.c

-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
