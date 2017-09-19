From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v3 00/12] net: dsa: b53/bcm_sf2 cleanups
Date: Tue, 19 Sep 2017 10:46:42 -0700
Message-ID: <20170919174654.2122-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36593 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751365AbdISRrE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 13:47:04 -0400
Received: by mail-wm0-f65.google.com with SMTP id r136so308418wmf.3
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 10:47:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patch series is a first pass set of clean-ups to reduce the number of LOCs
between b53 and bcm_sf2 and sharing as many functions as possible.

There is a number of additional cleanups queued up locally that require more
thorough testing.

Thanks!

Changes in v3:

- remove one extra argument for the b53_build_io_op macro (David Laight)
- added additional Reviewed-by tags from Vivien

Changes in v2:

- added Reviewed-by tags from Vivien
- added a missing EXPORT_SYMBOL() in patch 8
- fixed a typo in patch 5

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

 drivers/net/dsa/b53/b53_common.c | 151 ++++++++++++++++++++++++++++++++----
 drivers/net/dsa/b53/b53_priv.h   | 145 ++++++++---------------------------
 drivers/net/dsa/b53/b53_regs.h   |  48 ++++++++++++
 drivers/net/dsa/bcm_sf2.c        | 161 +++------------------------------------
 drivers/net/dsa/bcm_sf2.h        |   2 -
 drivers/net/dsa/bcm_sf2_cfp.c    |   6 +-
 drivers/net/dsa/bcm_sf2_regs.h   |  11 ---
 7 files changed, 228 insertions(+), 296 deletions(-)

-- 
2.9.3
