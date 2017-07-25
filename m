From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH v2 net-next 0/2] liquidio: standardization and cleanup
Date: Mon, 24 Jul 2017 17:15:59 -0700
Message-ID: <20170725001559.GA1146@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        ricardo.farrington@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0054.outbound.protection.outlook.com ([104.47.41.54]:4593
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753953AbdGYAQG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 24 Jul 2017 20:16:06 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Farrington <ricardo.farrington@cavium.com>

This patchset corrects some non-standard macro usage.

1. Replaced custom MIN macro with use of standard 'min_t'.
2. Removed cryptic and misleading macro 'CAST_ULL'.

change log:
V1 -> V2:
1. Added driver cleanup of macro 'CAST_ULL'.

Rick Farrington (2):
  liquidio: standardization: use min_t instead of custom macro
  liquidio: cleanup: removed cryptic and misleading macro

 drivers/net/ethernet/cavium/liquidio/octeon_console.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

-- 
2.9.0
