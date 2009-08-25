From: Alan Cox <alan@linux.intel.com>
Subject: [PATCH 00/26] et131x cleanups - phase 1
Date: Tue, 25 Aug 2009 15:57:26 +0100
Message-ID: <20090825145619.16176.68780.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: greg@kroah.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:42560 "EHLO
	bob.linux.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755057AbZHYPCx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 11:02:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Begin turning the et131x driver into something presentable. The only hairy
bit is the DMA10 stuff. Has all been lightly tested.

---

Alan Cox (26):
      et131x: clean up MP_FLAG macros
      et131x: clean up DMA10/DMA4 types
      et131x: clean up PM_CSR_t
      et131x: kill the Q_ADDR struct
      et131x: quick tidy of the debug code
      et131x: clean up MMC_SRAM_
      et131x: sort out the mmc enable routine
      et131x: eeprom remove features
      et131x: remove unused PCI identifiers
      et131x: continue pruning unused fields
      et131x: de-hungarianise a bit
      et131x: fold the diet config into the other code
      et131x: config is already zeroed
      et131x: attack the config stuff
      et131x: clean up constant rx/tx registry fields
      et131x: eliminate write only registry fields
      et131x: Eliminate RegistryDMA Cache
      et131x: CSRAddress to regs
      et131x: Take a kref for the PCI pointer we cache
      et131x: kill copied PCI fields
      et131x: MPSend macros
      et131x: kill refcount
      et131x: kill unused RCV_REF macros
      et131x: power state
      et131x: spinlocks
      et1310: kill pAdapter in favour of a sane name


 drivers/staging/et131x/Makefile             |    1 
 drivers/staging/et131x/et1310_address_map.h |  311 ++++----------
 drivers/staging/et131x/et1310_eeprom.c      |  190 ++++-----
 drivers/staging/et131x/et1310_eeprom.h      |   16 -
 drivers/staging/et131x/et1310_jagcore.c     |   73 +--
 drivers/staging/et131x/et1310_jagcore.h     |   19 -
 drivers/staging/et131x/et1310_mac.c         |  228 +++++------
 drivers/staging/et131x/et1310_phy.c         |  524 ++++++++++++------------
 drivers/staging/et131x/et1310_phy.h         |   37 --
 drivers/staging/et131x/et1310_pm.c          |   65 +--
 drivers/staging/et131x/et1310_pm.h          |   40 --
 drivers/staging/et131x/et1310_rx.c          |  365 ++++++++---------
 drivers/staging/et131x/et1310_rx.h          |    4 
 drivers/staging/et131x/et1310_tx.c          |  580 +++++++++++++--------------
 drivers/staging/et131x/et1310_tx.h          |    6 
 drivers/staging/et131x/et131x_adapter.h     |   74 ---
 drivers/staging/et131x/et131x_config.c      |  323 ---------------
 drivers/staging/et131x/et131x_debug.c       |  107 ++---
 drivers/staging/et131x/et131x_defs.h        |   16 -
 drivers/staging/et131x/et131x_initpci.c     |  300 ++++++++------
 drivers/staging/et131x/et131x_isr.c         |   60 +--
 drivers/staging/et131x/et131x_netdev.c      |   72 ++-

 delete mode 100644 drivers/staging/et131x/et131x_config.c

