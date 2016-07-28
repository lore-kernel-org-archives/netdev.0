From: Amir Levy <amir.jer.levy@intel.com>
Subject: [PATCH v5 0/8] thunderbolt: Introducing Thunderbolt(TM) networking
Date: Thu, 28 Jul 2016 11:15:13 +0300
Message-ID: <1469693721-5641-1-git-send-email-amir.jer.levy@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org,
	netdev@vger.kernel.org, linux-doc@vger.kernel.org,
	thunderbolt-linux@intel.com, mika.westerberg@intel.com,
	tomas.winkler@intel.com, Amir Levy <amir.jer.levy@intel.com>
To: andreas.noever@gmail.com, gregkh@linuxfoundation.org,
	bhelgaas@google.com, corbet@lwn.net
Return-path: <linux-doc-owner@vger.kernel.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is version 5 of Thunderbolt(TM) driver for non-Apple hardware.

Changes since v4:
 - Added Amir Levy as maintainer of thunderbolt/icm
 - Replaced private uuid definitions with uuid_be

These patches were pushed to GitHub where they can be reviewed more
comfortably with green/red highlighting:
	https://github.com/01org/thunderbolt-software-kernel-tree

Daemon code:
	https://github.com/01org/thunderbolt-software-daemon

For reference, here's a link to version 4:
[v4]:	https://lkml.org/lkml/2016/7/18/171

Amir Levy (8):
  thunderbolt: Macro rename
  thunderbolt: Updating the register definitions
  thunderbolt: Kconfig for Thunderbolt(TM) networking
  thunderbolt: Communication with the ICM (firmware)
  thunderbolt: Networking state machine
  thunderbolt: Networking transmit and receive
  thunderbolt: Networking doc
  thunderbolt: Adding maintainer entry

 Documentation/00-INDEX                   |    2 +
 Documentation/thunderbolt-networking.txt |  135 ++
 MAINTAINERS                              |    8 +-
 drivers/thunderbolt/Kconfig              |   25 +-
 drivers/thunderbolt/Makefile             |    3 +-
 drivers/thunderbolt/icm/Makefile         |   28 +
 drivers/thunderbolt/icm/icm_nhi.c        | 1641 +++++++++++++++++++++
 drivers/thunderbolt/icm/icm_nhi.h        |   93 ++
 drivers/thunderbolt/icm/net.c            | 2267 ++++++++++++++++++++++++++++++
 drivers/thunderbolt/icm/net.h            |  270 ++++
 drivers/thunderbolt/nhi_regs.h           |  115 +-
 11 files changed, 4578 insertions(+), 9 deletions(-)
 create mode 100644 Documentation/thunderbolt-networking.txt
 create mode 100644 drivers/thunderbolt/icm/Makefile
 create mode 100644 drivers/thunderbolt/icm/icm_nhi.c
 create mode 100644 drivers/thunderbolt/icm/icm_nhi.h
 create mode 100644 drivers/thunderbolt/icm/net.c
 create mode 100644 drivers/thunderbolt/icm/net.h

-- 
2.7.4

