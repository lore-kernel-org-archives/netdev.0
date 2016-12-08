From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next 0/5] liquidio VF offloads and stats
Date: Thu, 8 Dec 2016 13:00:43 -0800
Message-ID: <1481230848-2393-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
        Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0072.outbound.protection.outlook.com ([104.47.42.72]:2178
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752186AbcLHVBO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Dec 2016 16:01:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Following is final patch series in completing the liquidio
VF driver support. These patches have minor changes related
to offloads and stats.

Please apply patches in following order as some of them
depend on earlier patches.

Raghu Vatsavayi (5):
  liquidio VF vlan support
  liquidio VF vxlan
  liquidio VF ethtool stats
  liquidio VF timestamp
  liquidio VF error handling

 .../ethernet/cavium/liquidio/cn23xx_vf_device.h    |   2 +
 drivers/net/ethernet/cavium/liquidio/lio_ethtool.c | 512 ++++++++++++++----
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c | 575 ++++++++++++++++++++-
 3 files changed, 987 insertions(+), 102 deletions(-)

-- 
1.8.3.1
