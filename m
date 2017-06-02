From: Paul Burton <paul.burton@imgtec.com>
Subject: [PATCH v3 0/7] net: pch_gbe: Fixes & MIPS support
Date: Fri, 2 Jun 2017 16:40:35 -0700
Message-ID: <20170602234042.22782-1-paul.burton@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Tobias Klauser <tklauser@distanz.ch>,
        "David S . Miller" <davem@davemloft.net>,
        Jarod Wilson <jarod@redhat.com>, <linux-mips@linux-mips.org>,
        Eric Dumazet <edumazet@google.com>,
        Paul Burton <paul.burton@imgtec.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailapp01.imgtec.com ([195.59.15.196]:3731 "EHLO
        mailapp01.imgtec.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750971AbdFBXlD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2017 19:41:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Intel EG20T Platform Controller Hub is used on the MIPS Boston
development board to provide various peripherals including ethernet.
This series fixes some issues with the pch_gbe driver discovered whilst
in use on the Boston board, and implements support for device tree which
we use to provide the PHY reset GPIO.

Applies atop v4.12-rc3.

Paul Burton (7):
  net: pch_gbe: Mark Minnow PHY reset GPIO active low
  net: pch_gbe: Pull PHY GPIO handling out of Minnow code
  dt-bindings: net: Document Intel pch_gbe binding
  net: pch_gbe: Add device tree support
  net: pch_gbe: Always reset PHY along with MAC
  net: pch_gbe: Allow longer for resets
  net: pch_gbe: Allow build on MIPS platforms

 Documentation/devicetree/bindings/net/pch_gbe.txt  | 25 +++++++
 drivers/net/ethernet/oki-semi/pch_gbe/Kconfig      |  2 +-
 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h    |  4 +-
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   | 79 +++++++++++++++++-----
 4 files changed, 91 insertions(+), 19 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/pch_gbe.txt

-- 
2.13.0
