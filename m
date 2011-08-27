From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/6][pull request] Intel Wired LAN Driver Update
Date: Sat, 27 Aug 2011 00:09:25 -0700
Message-ID: <1314428971-7676-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:2448 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750865Ab1H0HJd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Aug 2011 03:09:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains updates to e1000e, ixgbe and ixgbevf.

The following are changes since commit 3cd0999d134235d64b175edd2eb1d46e=
bc97b377:
  Merge branch 'davem-next.mii' of git://git.kernel.org/pub/scm/linux/k=
ernel/git/romieu/netdev-2.6
and are available in the git repository at:
  master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-next master

Alexander Duyck (2):
  ixgbe: Simplify transmit cleanup path
  ixgbe: convert rings from q_vector bit indexed array to linked list

Bruce Allan (1):
  e1000e: convert to netdev features/hw_features API

Eric Dumazet (1):
  ixgbevf: provide 64 bit statistics

Greg Rose (1):
  ixgbevf: Check if EOP has changed before using it

Micha=C5=82 Miros=C5=82aw (1):
  ixgbevf: convert to ndo_fix_features

 drivers/net/ethernet/intel/e1000e/80003es2lan.c   |    1 -
 drivers/net/ethernet/intel/e1000e/82571.c         |    5 -
 drivers/net/ethernet/intel/e1000e/e1000.h         |    3 +-
 drivers/net/ethernet/intel/e1000e/ethtool.c       |   88 ---------
 drivers/net/ethernet/intel/e1000e/ich8lan.c       |    5 -
 drivers/net/ethernet/intel/e1000e/netdev.c        |   49 ++++--
 drivers/net/ethernet/intel/ixgbe/ixgbe.h          |    7 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |  202 +++++++------=
--------
 drivers/net/ethernet/intel/ixgbevf/ethtool.c      |   46 -----
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |    8 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   81 +++++++--
 11 files changed, 175 insertions(+), 320 deletions(-)

--=20
1.7.6
