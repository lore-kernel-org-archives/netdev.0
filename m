From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/2] net: dsa: mv88e6xxx: Fix a few build warnings
Date: Thu,  6 Apr 2017 06:47:34 -0700
Message-ID: <20170406134736.24329-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:35138 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755486AbdDFNrl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 09:47:41 -0400
Received: by mail-it0-f68.google.com with SMTP id y18so4387234itc.2
        for <netdev@vger.kernel.org>; Thu, 06 Apr 2017 06:47:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This fixes a bunch of warnings exposed by a make W=1, no functional changes

Florian Fainelli (2):
  net: dsa: mv88e6xxx: Fix warning with CONFIG_OF=n
  net: dsa: mv88e6xxx: Provide prototypes for SMI read/write functions

 drivers/net/dsa/mv88e6xxx/chip.c    | 2 ++
 drivers/net/dsa/mv88e6xxx/global2.h | 9 +++++++++
 2 files changed, 11 insertions(+)

-- 
2.9.3
