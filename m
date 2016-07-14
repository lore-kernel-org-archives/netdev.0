From: Amir Levy <amir.jer.levy@intel.com>
Subject: [PATCH v3 0/8] thunderbolt: Introducing Thunderbolt(TM) networking
Date: Thu, 14 Jul 2016 14:28:14 +0300
Message-ID: <1468495702-7467-1-git-send-email-amir.jer.levy@intel.com>
Cc: linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, thunderbolt-linux@intel.com,
	mika.westerberg@intel.com, tomas.winkler@intel.com,
	Amir Levy <amir.jer.levy@intel.com>
To: andreas.noever@gmail.com, gregkh@linuxfoundation.org,
	bhelgaas@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is version 3 of Thunderbolt(TM) driver for non-Apple hardware.

Changes since v2:
 - Moved ICM code to subdirectory - thunderbolt/icm

These patches were pushed to GitHub where they can be reviewed more
comfortably with green/red highlighting:
	https://github.com/01org/thunderbolt-software-kernel-tree

Daemon code:
	https://github.com/01org/thunderbolt-software-daemon

For reference, here's a link to version 2:
[v2]:	https://lkml.org/lkml/2016/6/29/160

Amir Levy (8):
  thunderbolt: Macro rename
  thunderbolt: Updating device IDs
  thunderbolt: Updating the register definitions
  thunderbolt: Kconfig for Thunderbolt(TM) networking
  thunderbolt: Communication with the ICM (firmware)
  thunderbolt: Networking state machine
  thunderbolt: Networking transmit and receive
  thunderbolt: Networking doc

 Documentation/00-INDEX                   |    2 +
 Documentation/thunderbolt-networking.txt |  135 ++
 drivers/thunderbolt/Kconfig              |   25 +-
 drivers/thunderbolt/Makefile             |    3 +-
 drivers/thunderbolt/icm/Makefile         |   28 +
 drivers/thunderbolt/icm/icm_nhi.c        | 1631 +++++++++++++++++++++
 drivers/thunderbolt/icm/icm_nhi.h        |   84 ++
 drivers/thunderbolt/icm/net.c            | 2277 ++++++++++++++++++++++++++++++
 drivers/thunderbolt/icm/net.h            |  274 ++++
 drivers/thunderbolt/nhi_regs.h           |  115 +-
 include/linux/pci_ids.h                  |   44 +-
 11 files changed, 4592 insertions(+), 26 deletions(-)
 create mode 100644 Documentation/thunderbolt-networking.txt
 create mode 100644 drivers/thunderbolt/icm/Makefile
 create mode 100644 drivers/thunderbolt/icm/icm_nhi.c
 create mode 100644 drivers/thunderbolt/icm/icm_nhi.h
 create mode 100644 drivers/thunderbolt/icm/net.c
 create mode 100644 drivers/thunderbolt/icm/net.h

-- 
2.7.4
