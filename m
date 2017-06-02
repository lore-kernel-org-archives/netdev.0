From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH 0/3] net: dsa: Cleanups before multi-CPU port
Date: Fri,  2 Jun 2017 12:31:20 -0700
Message-ID: <20170602193123.23930-1-f.fainelli@gmail.com>
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        john@phrozen.org, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36379 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750918AbdFBTbc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2017 15:31:32 -0400
Received: by mail-wm0-f66.google.com with SMTP id k15so20481713wmh.3
        for <netdev@vger.kernel.org>; Fri, 02 Jun 2017 12:31:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patch series does a bunch of cleanups before we start adding support
for multiple CPU ports.

Florian Fainelli (3):
  net: dsa: Pass dsa_port reference to ethtool setup/restore
  net: dsa: Consistently use dsa_port for dsa_*_port_{apply,unapply}
  net: dsa: Initialize all CPU and enabled ports masks in dsa_ds_parse()

 include/net/dsa.h  |   2 +-
 net/dsa/dsa.c      |   6 ++-
 net/dsa/dsa2.c     | 125 ++++++++++++++++++++++++-----------------------------
 net/dsa/dsa_priv.h |   4 +-
 net/dsa/legacy.c   |   4 +-
 5 files changed, 66 insertions(+), 75 deletions(-)

-- 
2.9.3
