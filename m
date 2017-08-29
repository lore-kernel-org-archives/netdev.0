From: Vadim Pasternak <vadimp-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [patch v1 0/2] add support for the external thermal zone and cooling device binding for Mellanox network devices
Date: Tue, 29 Aug 2017 18:45:09 +0000
Message-ID: <1504032311-195988-1-git-send-email-vadimp@mellanox.com>
Cc: jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org, ivecera-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Vadim Pasternak <vadimp-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

It allows binding of AISC thermal sensor to externally defined thermal
zones and cooling device. Such definition can be provided from DTS.

Vadim Pasternak (2):
  dt-bindings: net: add binding documentation for mlxsw thermal control
  mlxsw: core: add support for the external thermal zone setting (by
    DTS)

 .../devicetree/bindings/net/mellanox,mlxsw.txt     |  46 +++++++++
 drivers/net/ethernet/mellanox/mlxsw/core_thermal.c | 107 ++++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlxsw/minimal.c      |   6 ++
 3 files changed, 155 insertions(+), 4 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/mellanox,mlxsw.txt

-- 
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
