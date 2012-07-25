From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: [RFC NET-NEXT PATCH 0/6] implement MDI-X set support in Intel drivers
Date: Wed, 25 Jul 2012 10:59:59 -0700
Message-ID: <20120725175430.9995.11370.stgit@jbrandeb-snb.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, jesse.brandeburg@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:45999 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751464Ab2GYUwB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jul 2012 16:52:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an update (v2) to the patches sent previously.

This series implements MDI-X set support in the Intel gigabit ethernet
drivers.  It specifically allows a user to control the MDI state,
in order for them to work around issues with broken switches.

The only change to this series is updated descriptions and an
addition of reporting the current mdix_ctrl value in the
"get_settings" functions, which allows the new extended reporting
in the ethtool app's MDI-X: line

sent as RFC for now to get feedback while internal testing
completes. (and net-next is closed)

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>

---

Bruce W Allan (1):
      e1000e: implement 82577/579 MDI setting support

Jesse Brandeburg (5):
      igb: update to allow reading/setting MDI state
      e1000e: implement MDI/MDI-X control
      e1000: configure and read MDI settings
      igb: implement 580 MDI setting support
      ethtool.h: MDI setting support


 drivers/net/ethernet/intel/e1000/e1000_ethtool.c |   39 ++++++++++++++++++++
 drivers/net/ethernet/intel/e1000/e1000_main.c    |    4 ++
 drivers/net/ethernet/intel/e1000e/ethtool.c      |   41 ++++++++++++++++++++-
 drivers/net/ethernet/intel/e1000e/phy.c          |   31 +++++++++++++++-
 drivers/net/ethernet/intel/igb/e1000_phy.c       |   29 ++++++++++++++-
 drivers/net/ethernet/intel/igb/e1000_phy.h       |    5 ++-
 drivers/net/ethernet/intel/igb/igb_ethtool.c     |   42 ++++++++++++++++++++++
 drivers/net/ethernet/intel/igb/igb_main.c        |    4 ++
 include/linux/ethtool.h                          |   17 ++++++---
 9 files changed, 198 insertions(+), 14 deletions(-)

--
Jesse Brandeburg
