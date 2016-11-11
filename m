From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 00/11] Start adding support for mv88e6390 family
Date: Fri, 11 Nov 2016 03:53:32 +0100
Message-ID: <1478832823-31471-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:34683 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965482AbcKKC6p (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 10 Nov 2016 21:58:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the first patchset implementing support for the mv88e6390
family.  This is a new generation of switch devices and has numerous
incompatible changes to the registers. These patches allow the switch
to the detected during probe, and makes the statistics unit work.

These patches are insufficient to make the mv88e6390 functional. More
patches will follow.

Andrew Lunn (11):
  net: dsa: mv88e6xxx: Take switch out of reset before probe
  net: dsa: mv88e6xxx: Fix unused variable warning by using variable
  net: dsa: mv88e6xxx: Add the mv88e6390 family
  net: dsa: mv88e6xxx: Abstract stats_snapshot into ops structure
  net: dsa: mv88e6xxx: Add comment about family a device belongs to
  net: dsa: mv88e6xxx: Add mv88e6390 stats snapshot operation
  net: dsa: mv88e6xxx: Add mv88e6390 statistics unit init
  net: dsa: mv88e6xxx: Add stats_get_sset_count to ops structure
  net: dsa: mv88e6xxx: Add stats_get_strings to ops structure
  net: dsa: mv88e6xxx: Add stats_get_stats to ops structure
  net: dsa: mv88e6xxx: Implement mv88e6390 get_stats

 .../devicetree/bindings/net/dsa/marvell.txt        |   3 +-
 drivers/net/dsa/mv88e6xxx/chip.c                   | 550 ++++++++++++++++-----
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h              |  53 +-
 3 files changed, 487 insertions(+), 119 deletions(-)

-- 
2.10.1
