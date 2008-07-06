From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 00/06]: VLAN TCI truncation fixes
Date: Mon, 07 Jul 2008 00:48:03 +0200
Message-ID: <48714BA3.3080102@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	john.ronciak@intel.com, ionut@cs.columbia.edu,
	baum@tehutinetworks.net, andy@greyhouse.net
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42084 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754955AbYGFWyH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jul 2008 18:54:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches fix all drivers supporting VLAN header stripping to
pass the complete VLAN TCI to vlan_hwaccel_{rx,receive_skb} instead
of just the VID. The upper three bits contain the priority and are
used for ingress priority mappings.

The e1000 patch is runtime tested, the others only compile tested.


 drivers/net/e1000/e1000_main.c |   12 ++++--------
 drivers/net/e1000e/netdev.c    |    3 +--
 drivers/net/igb/igb_main.c     |    3 +--
 drivers/net/ixgb/ixgb_main.c   |    6 ++----
 drivers/net/starfire.c         |    2 +-
 drivers/net/tehuti.c           |    2 +-
 drivers/net/tehuti.h           |    1 +
 7 files changed, 11 insertions(+), 18 deletions(-)

Patrick McHardy (6):
      e1000: don't truncate VLAN TCI with VLAN stripping
      e1000e: don't truncate VLAN TCI with VLAN stripping
      igb: don't truncate VLAN TCI with VLAN stripping
      ixgb: don't truncate VLAN TCI with VLAN stripping
      starfire: don't truncate VLAN TCI with VLAN stripping
      tehuti: don't truncate VLAN TCI with VLAN stripping

