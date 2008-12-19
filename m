From: David Daney <ddaney@caviumnetworks.com>
Subject: [PATCH 0/3] Add driver for OCTEON MGMT ethernet device.
Date: Fri, 19 Dec 2008 15:41:34 -0800
Message-ID: <494C312E.9000901@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: linux-mips <linux-mips@linux-mips.org>, netdev@vger.kernel.org
Return-path: <linux-mips-bounce@linux-mips.org>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

Queued for inclusion in 2.6.29 is support for the Cavium OCTEON
processor.  See:

http://marc.info/?l=linux-mips&m=122903840412896&w=2
http://marc.info/?l=linux-mips&m=122972878908450&w=2

This patch set adds support for the OCTEON SOC's on-board mgmt ethernet
devices.

The first patch is not too interesting, it adds a missing function to
the boot monitor memory allocator.  This is needed by the third patch.

Second I add register definitions for the hardware blocks used by the
driver.  This is just a lot of boiler plate.

Third is the main driver patch.

I anticipate that some changes may have to be made to the driver, but
I wanted to get some feedback before proceeding.  So please let me
know what you think should change with an eye to getting the driver
merged.

I will reply with the three patches.

David Daney (3):
  MIPS: Add named alloc functions to OCTEON boot monitor memory
    allocator.
  MIPS: Add some register definitions to OCTEON for MGMT ethernet
    driver.
  netdev: New driver for OCTEON's MGMT ethernet devices.

 arch/mips/cavium-octeon/executive/cvmx-bootmem.c |  101 ++
 arch/mips/include/asm/octeon/cvmx-agl-defs.h     | 1194 ++++++++++++++++++++++
 arch/mips/include/asm/octeon/cvmx-bootmem.h      |   85 ++
 arch/mips/include/asm/octeon/cvmx-mdio.h         |  577 +++++++++++
 arch/mips/include/asm/octeon/cvmx-mixx-defs.h    |  248 +++++
 arch/mips/include/asm/octeon/cvmx-smix-defs.h    |  178 ++++
 drivers/net/Kconfig                              |    8 +
 drivers/net/Makefile                             |    1 +
 drivers/net/octeon/Makefile                      |   11 +
 drivers/net/octeon/cvmx-mgmt-port.c              |  818 +++++++++++++++
 drivers/net/octeon/cvmx-mgmt-port.h              |  168 +++
 drivers/net/octeon/octeon-mgmt-port.c            |  389 +++++++
 12 files changed, 3778 insertions(+), 0 deletions(-)
 create mode 100644 arch/mips/include/asm/octeon/cvmx-agl-defs.h
 create mode 100644 arch/mips/include/asm/octeon/cvmx-mdio.h
 create mode 100644 arch/mips/include/asm/octeon/cvmx-mixx-defs.h
 create mode 100644 arch/mips/include/asm/octeon/cvmx-smix-defs.h
 create mode 100644 drivers/net/octeon/Makefile
 create mode 100644 drivers/net/octeon/cvmx-mgmt-port.c
 create mode 100644 drivers/net/octeon/cvmx-mgmt-port.h
 create mode 100644 drivers/net/octeon/octeon-mgmt-port.c
