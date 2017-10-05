From: Razvan Stefanescu <razvan.stefanescu@nxp.com>
Subject: [PATCH v3 0/6] staging: Introduce DPAA2 Ethernet Switch driver
Date: Thu, 5 Oct 2017 12:16:08 +0300
Message-ID: <1507194974-12050-1-git-send-email-razvan.stefanescu@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, arnd@arndb.de, netdev@vger.kernel.org,
 alexandru.marginean@nxp.com, linux-kernel@vger.kernel.org, agraf@suse.de,
 stuyoder@gmail.com, bogdan.purcareata@nxp.com, laurentiu.tudor@nxp.com
To: <gregkh@linuxfoundation.org>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
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

Changelog:
 v2: addressed comments from Bogdan P.
 
 v3: addressed comments from Andrew L. (patch 3/6 updated)

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
 drivers/staging/fsl-dpaa2/ethsw/ethsw-ethtool.c |  206 +++
 drivers/staging/fsl-dpaa2/ethsw/ethsw.c         | 1532 +++++++++++++++++++++++
 drivers/staging/fsl-dpaa2/ethsw/ethsw.h         |   90 ++
 12 files changed, 4099 insertions(+)
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
