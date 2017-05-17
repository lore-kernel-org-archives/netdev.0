From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 0/3] net: dsa: mv88e6xxx: Add basic SERDES support
Date: Wed, 17 May 2017 22:05:09 +0200
Message-ID: <1495051512-13554-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, nikita.yoush@cogentembedded.com,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:34763 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751725AbdEQUFc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 17 May 2017 16:05:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some of the Marvell switches are SERDES interface, which must be
powered up before packets can be passed. This is particularly true on
the 6390, where the SERDES defaults to down, probably to save power.

This series refactors the existing SERDES support for the 6352, and
adds 6390 support.

Andrew Lunn (3):
  net: dsa: mv88e6xxx: Refactor mv88e6352 SERDES code into an op
  net: dsa: mv88e6xxx: mv88e6390X SERDES support
  dsa: mv88e6xxx: Enable/Disable SERDES on port enable/disable

 drivers/net/dsa/mv88e6xxx/Makefile    |   1 +
 drivers/net/dsa/mv88e6xxx/chip.c      | 120 +++++++++---------
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  39 +++---
 drivers/net/dsa/mv88e6xxx/serdes.c    | 231 ++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/serdes.h    |  45 +++++++
 5 files changed, 351 insertions(+), 85 deletions(-)
 create mode 100644 drivers/net/dsa/mv88e6xxx/serdes.c
 create mode 100644 drivers/net/dsa/mv88e6xxx/serdes.h

-- 
2.11.0
