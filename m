From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 00/10] switchdev: transaction item queue and cleanup
Date: Wed, 23 Sep 2015 09:57:48 +0200
Message-ID: <1442995078-10491-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com, rami.rosen@intel.com,
	roopa@cumulusnetworks.com, pjonnala@broadcom.com, andrew@lunn.ch,
	gospo@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:36779 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752456AbbIWH6C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 03:58:02 -0400
Received: by wicgb1 with SMTP id gb1so193167085wic.1
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 00:58:01 -0700 (PDT)
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
 drivers/net/ethernet/rocker/rocker.c   | 306 ++++++++++++++-------------------
 include/net/switchdev.h                |  40 +++--
 net/dsa/slave.c                        |  31 ++--
 net/switchdev/switchdev.c              | 117 ++++++++++---
 5 files changed, 287 insertions(+), 226 deletions(-)

-- 
1.9.3
