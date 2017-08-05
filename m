From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 0/3] net: dsa: remove useless arguments
Date: Sat,  5 Aug 2017 16:20:16 -0400
Message-ID: <20170805202019.1679-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:48652 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751519AbdHEUXZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 5 Aug 2017 16:23:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Several DSA core setup functions take many arguments, mostly because of
the legacy code. This patch series removes the useless args of these
functions, where either the dsa_switch or dsa_port argument is enough.

Changes in v2:
  - ds->dev is already assigned by dsa_switch_alloc

Vivien Didelot (3):
  net: dsa: remove useless argument in legacy setup
  net: dsa: remove useless args of dsa_cpu_dsa_setup
  net: dsa: remove useless args of dsa_slave_create

 net/dsa/dsa.c      | 10 +++++-----
 net/dsa/dsa2.c     |  6 +++---
 net/dsa/dsa_priv.h |  6 ++----
 net/dsa/legacy.c   | 18 ++++++++----------
 net/dsa/slave.c    | 14 +++++++-------
 5 files changed, 25 insertions(+), 29 deletions(-)

-- 
2.13.3
