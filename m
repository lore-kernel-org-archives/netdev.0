From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Sat, 19 Apr 2008 21:38:42 -0700 (PDT)
Message-ID: <20080419.213842.12435812.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39257
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750856AbYDTEil (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Apr 2008 00:38:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This fixes various small bits of build fallout, integrates some ATM
and hci_usb bluetooth cleanup/fixup patches that came in via Andrew, a
ROSE locking bug fix, and a tg3 driver DMA data corruption fix.

Please pull, thanks a lot!

The following changes since commit 3925e6fc1f774048404fdd910b0345b06c699eb4:
  Linus Torvalds (1):
        Merge branch 'for-linus' of git://git.kernel.org/.../jmorris/security-testing-2.6

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Bernard Pidoux (1):
      rose: Socket lock was not released before returning to user space

David S. Miller (1):
      iwlwifi: Fix unconditional access to station->tidp[].agg.

Julia Lawall (2):
      drivers/atm: use time_before, time_before_eq, etc
      drivers/net/appletalk: use time_before, time_before_eq, etc

Mark Asselstine (1):
      atm nicstar: Removal of debug code containing deprecated calls to cli()/sti()

Matt Carlson (1):
      tg3: 5701 DMA corruption fix

Patrick McHardy (2):
      netfilter: Fix SCTP nat build.
      netfilter: Fix SIP conntrack build with NAT disabled.

Pavel Machek (2):
      hci_usb: do not initialize static variables to 0
      hci_usb: remove code obfuscation

 drivers/atm/iphase.c                       |    7 +-
 drivers/atm/nicstar.c                      |  117 +++++-----------------------
 drivers/atm/nicstar.h                      |   12 ---
 drivers/bluetooth/hci_usb.c                |   24 +++---
 drivers/bluetooth/hci_usb.h                |    5 -
 drivers/net/appletalk/cops.c               |    3 +-
 drivers/net/tg3.c                          |   52 +++++++++++-
 drivers/net/tg3.h                          |    1 +
 drivers/net/wireless/iwlwifi/iwl-debugfs.c |   18 +++--
 net/ipv4/netfilter/Kconfig                 |    1 +
 net/netfilter/nf_conntrack_sip.c           |    3 +-
 net/rose/af_rose.c                         |    6 +-
 12 files changed, 105 insertions(+), 144 deletions(-)
