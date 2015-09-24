From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 00/10] switchdev: transaction item queue and cleanup
Date: Thu, 24 Sep 2015 10:02:39 +0200
Message-ID: <1443081769-11193-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com, rami.rosen@intel.com,
	roopa@cumulusnetworks.com, pjonnala@broadcom.com, andrew@lunn.ch,
	gospo@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:38782 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751387AbbIXICw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 04:02:52 -0400
Received: by wiclk2 with SMTP id lk2so101452819wic.1
        for <netdev@vger.kernel.org>; Thu, 24 Sep 2015 01:02:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Jiri Pirko (10):
  switchdev: rename "trans" to "trans_ph".
  switchdev: introduce transaction item queue for attr_set and obj_add
  switchdev: move transaction phase enum under transaction structure
  switchdev: add switchdev_trans_ph_prepare/commit helpers
  rocker: push struct switchdev_trans down through rocker code
  rocker: use switchdev transaction queue for allocated memory
  switchdev: remove "NONE" transaction phase
  switchdev: remove "ABORT" transaction phase
  dsa: use prepare/commit switchdev transaction helpers
  switchdev: reduce transaction phase enum down to a boolean

 Documentation/networking/switchdev.txt |  19 ++
 drivers/net/ethernet/rocker/rocker.c   | 308 ++++++++++++++-------------------
 include/net/switchdev.h                |  40 +++--
 net/dsa/slave.c                        |  31 ++--
 net/switchdev/switchdev.c              | 125 ++++++++++---
 5 files changed, 296 insertions(+), 227 deletions(-)

-- 
1.9.3
