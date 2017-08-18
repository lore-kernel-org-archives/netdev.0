From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next 0/2] liquidio: initialization fixes for embedded
 firmware
Date: Thu, 17 Aug 2017 23:10:37 -0700
Message-ID: <20170818061037.GA4024@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        ricardo.farrington@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0050.outbound.protection.outlook.com ([104.47.42.50]:12560
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751045AbdHRGK3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 18 Aug 2017 02:10:29 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Farrington <ricardo.farrington@cavium.com>

Fix problems when using an adapter w/embedded f/w (param "fw_type=none").

1. Add support for PF FLR when exiting.
2. Skip some initialization (don't try to load f/w, activate consoles).
3. Issue credits BEFORE enabling DROQs.

Rick Farrington (2):
  liquidio: with embedded f/w, don't reload f/w, issue pf flr at exit
  liquidio: with embedded f/w, issue droq credits before enablement

 drivers/net/ethernet/cavium/liquidio/lio_main.c | 90 ++++++++++++++++---------
 1 file changed, 58 insertions(+), 32 deletions(-)

-- 
2.9.0
