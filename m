From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC PATCH net-next 0/3] net: dsa: finer bridging control
Date: Sun, 13 Mar 2016 01:42:23 -0500
Message-ID: <1457851346-26257-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, Jiri Pirko <jiri@resnulli.us>,
	Ido Schimmel <idosch@mellanox.com>,
	Kevin Smith <kevin.smith@elecsyscorp.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:34384 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750769AbcCMGmz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2016 01:42:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset renames the bridging routines of the DSA layer, make the
unbridging routine return void, and rework the DSA netdev notifier handler,
similar to what the Mellanox Spectrum driver does.

Vivien Didelot (3):
  net: dsa: rename port_*_bridge routines
  net: dsa: make port_bridge_leave return void
  net: dsa: refine netdev event notifier

 Documentation/networking/dsa/dsa.txt |  4 +--
 drivers/net/dsa/bcm_sf2.c            |  8 ++---
 drivers/net/dsa/mv88e6171.c          |  4 +--
 drivers/net/dsa/mv88e6352.c          |  4 +--
 drivers/net/dsa/mv88e6xxx.c          | 28 +++++----------
 drivers/net/dsa/mv88e6xxx.h          |  2 +-
 include/net/dsa.h                    |  4 +--
 net/dsa/slave.c                      | 68 +++++++++++++++++++-----------------
 8 files changed, 57 insertions(+), 65 deletions(-)

-- 
2.7.2
