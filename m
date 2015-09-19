From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 0/6] switchdev: introduce tranction enfra and for pre-commit split
Date: Sat, 19 Sep 2015 14:29:05 +0200
Message-ID: <1442665751-10949-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:38194 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751493AbbISM3P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Sep 2015 08:29:15 -0400
Received: by wiclk2 with SMTP id lk2so59507051wic.1
        for <netdev@vger.kernel.org>; Sat, 19 Sep 2015 05:29:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko (6):
  switchdev: rename "trans" to "trans_ph".
  switchdev: introduce transaction infrastructure for attr_set and
    obj_add
  rocker: switch to local transaction phase enum
  switchdev: move transaction phase enum under transaction structure
  rocker: use switchdev transaction queue for allocated memory
  switchdev: split commit and prepare phase into two callbacks

 drivers/net/ethernet/rocker/rocker.c | 579 ++++++++++++++++++-----------------
 include/net/switchdev.h              |  39 ++-
 net/dsa/slave.c                      | 129 +++++---
 net/switchdev/switchdev.c            | 153 +++++++--
 4 files changed, 545 insertions(+), 355 deletions(-)

-- 
1.9.3
