From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 00/10] switchdev: transaction item queue and cleanup
Date: Tue, 22 Sep 2015 15:53:42 +0200
Message-ID: <1442930031-4732-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com, rami.rosen@intel.com,
	roopa@cumulusnetworks.com, pjonnala@broadcom.com, andrew@lunn.ch,
	gospo@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:37701 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757914AbbIVNx4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 09:53:56 -0400
Received: by wicfx3 with SMTP id fx3so25097271wic.0
        for <netdev@vger.kernel.org>; Tue, 22 Sep 2015 06:53:54 -0700 (PDT)
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

 drivers/net/ethernet/rocker/rocker.c | 311 +++++++++++++++--------------------
 include/net/switchdev.h              |  40 +++--
 net/dsa/slave.c                      |  31 ++--
 net/switchdev/switchdev.c            |  99 ++++++++---
 4 files changed, 252 insertions(+), 229 deletions(-)

-- 
1.9.3
