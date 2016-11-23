From: Stefan Eichenberger <eichest@gmail.com>
Subject: [PATCH net-next v2 0/2] Add support for the MV88e6097
Date: Wed, 23 Nov 2016 21:59:50 +0100
Message-ID: <20161123205952.6231-1-stefan.eichenberger@netmodule.com>
Cc: netdev@vger.kernel.org,
        Stefan Eichenberger <stefan.eichenberger@netmodule.com>
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34426 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750997AbcKWVNr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 16:13:47 -0500
Received: by mail-wm0-f67.google.com with SMTP id g23so3174341wme.1
        for <netdev@vger.kernel.org>; Wed, 23 Nov 2016 13:13:46 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset will add support for the MV88E6097 DSA switch and enable
EDSA on MV88E6097 family devices.

Changes since v1:
- Add missing g1_irqs = 8
- Add missing comment after mv88e6097_ops
- Change patch order

Stefan Eichenberger (2):
  net: dsa: mv88e6xxx: enable EDSA on mv88e6097
  net: dsa: mv88e6xxx: add MV88E6097 switch

 drivers/net/dsa/mv88e6xxx/chip.c      | 28 ++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  5 ++++-
 2 files changed, 32 insertions(+), 1 deletion(-)

-- 
2.9.3
