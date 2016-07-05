From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 0/4] net: dsa: Preparatory patches for pdata
Date: Tue,  5 Jul 2016 15:07:09 -0700
Message-ID: <1467756433-25062-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
	vivien.didelot@savoirfairelinux.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:34634 "EHLO
	mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755577AbcGEWHU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 18:07:20 -0400
Received: by mail-pa0-f67.google.com with SMTP id us13so19321662pab.1
        for <netdev@vger.kernel.org>; Tue, 05 Jul 2016 15:07:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This is a resend of the patches that just clean up and prepare net/dsa/dsa2.c
to support platform data in the future.

Florian Fainelli (4):
  net: dsa: Pass device pointer to dsa_register_switch
  net: dsa: Make most functions take a dsa_port argument
  net: dsa: Suffix function manipulating device_node with _dn
  net: dsa: Move ports assignment closer to error checking

 drivers/net/dsa/b53/b53_common.c |  2 +-
 drivers/net/dsa/mv88e6xxx/chip.c |  7 ++--
 include/net/dsa.h                |  2 +-
 net/dsa/dsa.c                    | 14 ++++---
 net/dsa/dsa2.c                   | 87 ++++++++++++++++++++++------------------
 net/dsa/dsa_priv.h               |  4 +-
 6 files changed, 62 insertions(+), 54 deletions(-)

-- 
2.7.4
