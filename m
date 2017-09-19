From: Razvan Stefanescu <razvan.stefanescu@nxp.com>
Subject: [RESEND PATCH 0/6] staging: Introduce DPAA2 Ethernet Switch driver
Date: Tue, 19 Sep 2017 15:45:52 +0300
Message-ID: <1505825158-8192-1-git-send-email-razvan.stefanescu@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <devel@driverdev.osuosl.org>, <linux-kernel@vger.kernel.org>,
        <netdev@vger.kernel.org>, <agraf@suse.de>, <arnd@arndb.de>,
        <alexandru.marginean@nxp.com>, <bogdan.purcareata@nxp.com>,
        <ruxandra.radulescu@nxp.com>, <laurentiu.tudor@nxp.com>,
        <stuyoder@gmail.com>
To: <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset introduces the Ethernet Switch Driver for Freescale/NXP SoCs
with DPAA2 (DataPath Acceleration Architecture v2). The driver manages
switch objects discovered on the fsl-mc bus. A description of the driver
can be found in the associated README file.

The patchset consists of:
* A set of libraries containing APIs for configuring and controlling
  Management Complex (MC) switch objects
* The DPAA2 Ethernet Switch driver
* Patch adding ethtool support

Limitations:
* no support for control traffic to/from CPU
* only DPSW ports can be added to a bridge

Resending in order to add the netdev list (and remove the arm one), based
on Andrew Lunn's suggestion.

Razvan Stefanescu (6):
  staging: fsl-dpaa2/ethsw: Add APIs for DPSW object
  staging: fsl-dpaa2/ethsw: Add Freescale DPAA2 Ethernet Switch driver
  staging: fsl-dpaa2/ethsw: Add ethtool support
  staging: fsl-dpaa2/ethsw: Add maintainer for Ethernet Switch driver
  staging: fsl-dpaa2/ethsw: Add README
  staging: fsl-dpaa2/ethsw: Add TODO

 MAINTAINERS                                     |    6 +
 drivers/staging/fsl-dpaa2/Kconfig               |    8 +
 drivers/staging/fsl-dpaa2/Makefile              |    1 +
 drivers/staging/fsl-dpaa2/ethsw/Makefile        |    7 +
 drivers/staging/fsl-dpaa2/ethsw/README          |  106 ++
 drivers/staging/fsl-dpaa2/ethsw/TODO            |   14 +
 drivers/staging/fsl-dpaa2/ethsw/dpsw-cmd.h      |  371 ++++++
 drivers/staging/fsl-dpaa2/ethsw/dpsw.c          | 1147 +++++++++++++++++
 drivers/staging/fsl-dpaa2/ethsw/dpsw.h          |  611 +++++++++
 drivers/staging/fsl-dpaa2/ethsw/ethsw-ethtool.c |  207 +++
 drivers/staging/fsl-dpaa2/ethsw/ethsw.c         | 1526 +++++++++++++++++++++++
 drivers/staging/fsl-dpaa2/ethsw/ethsw.h         |   91 ++
 12 files changed, 4095 insertions(+)
 create mode 100644 drivers/staging/fsl-dpaa2/ethsw/Makefile
 create mode 100644 drivers/staging/fsl-dpaa2/ethsw/README
 create mode 100644 drivers/staging/fsl-dpaa2/ethsw/TODO
 create mode 100644 drivers/staging/fsl-dpaa2/ethsw/dpsw-cmd.h
 create mode 100644 drivers/staging/fsl-dpaa2/ethsw/dpsw.c
 create mode 100644 drivers/staging/fsl-dpaa2/ethsw/dpsw.h
 create mode 100644 drivers/staging/fsl-dpaa2/ethsw/ethsw-ethtool.c
 create mode 100644 drivers/staging/fsl-dpaa2/ethsw/ethsw.c
 create mode 100644 drivers/staging/fsl-dpaa2/ethsw/ethsw.h

-- 
1.9.1
