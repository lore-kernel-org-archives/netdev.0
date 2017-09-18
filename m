From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 00/12] net: dsa: b53/bcm_sf2 cleanups
Date: Mon, 18 Sep 2017 14:41:16 -0700
Message-ID: <20170918214128.27896-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:34468 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751210AbdIRVlg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 17:41:36 -0400
Received: by mail-wr0-f194.google.com with SMTP id k20so1141839wre.1
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 14:41:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patch series is a first pass set of clean-ups to reduce the number of LOCs
between b53 and bcm_sf2 and sharing as many functions as possible.

There is a number of additional cleanups queued up locally that require more
thorough testing.

Thanks!

Florian Fainelli (12):
  net: dsa: b53: Remove is_cpu_port()
  net: dsa: b53: Make b53_enable_cpu_port() take a port argument
  net: dsa: b53: Defer port enabling to calling port_enable
  net: dsa: bcm_sf2: Defer port enabling to calling port_enable
  net: dsa: b53: Use a macro to define I/O operations
  net: dsa: b53: Move Broadcom header setup to b53
  net: dsa: b53: Define EEE register page
  net: dsa: b53: Move EEE functions to b53
  net: dsa: b53: Wire-up EEE
  net: dsa: b53: Export b53_imp_vlan_setup()
  net: dsa: bcm_sf2: Use SF2_NUM_EGRESS_QUEUES for CFP
  net: dsa: bcm_sf2: Utilize b53_{enable,disable}_port

 drivers/net/dsa/b53/b53_common.c | 150 ++++++++++++++++++++++++++++++++----
 drivers/net/dsa/b53/b53_priv.h   | 145 ++++++++---------------------------
 drivers/net/dsa/b53/b53_regs.h   |  48 ++++++++++++
 drivers/net/dsa/bcm_sf2.c        | 161 +++------------------------------------
 drivers/net/dsa/bcm_sf2.h        |   2 -
 drivers/net/dsa/bcm_sf2_cfp.c    |   6 +-
 drivers/net/dsa/bcm_sf2_regs.h   |  11 ---
 7 files changed, 227 insertions(+), 296 deletions(-)

-- 
2.9.3
