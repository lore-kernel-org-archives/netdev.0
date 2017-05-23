From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH v2 net-next 0/2] Start making stats consistent
Date: Tue, 23 May 2017 23:10:56 +0200
Message-ID: <1495573858-32346-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        hayeswang <hayeswang@realtek.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:42174 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1162380AbdEWVME (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 May 2017 17:12:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It does not appear that the sysfs class net stats have been clearly
defined, resulting in different network interfaces implementing them
slightly different. Define that the rx_bytes and tx_bytes counters
should include the Ethernet header, data and FEC. Modify the r8152 USB
Ethernet driver to include the FEC in its counters.

Andrew Lunn (2):
  Documentation: sysfs-class-net-statistics: Clarify rx_bytes and
    tx_bytes
  net: usb: r8152: Fix rx_bytes/tx_bytes to include FCS

 Documentation/ABI/testing/sysfs-class-net-statistics | 6 ++++--
 drivers/net/usb/r8152.c                              | 5 ++---
 2 files changed, 6 insertions(+), 5 deletions(-)

-- 
2.11.0
