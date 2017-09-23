From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next 0/3] liquidio: firmware loading
Date: Fri, 22 Sep 2017 17:12:06 -0700
Message-ID: <20170923001206.GA1458@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        ricardo.farrington@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0059.outbound.protection.outlook.com ([104.47.42.59]:43865
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751845AbdIWAMN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 22 Sep 2017 20:12:13 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Farrington <ricardo.farrington@cavium.com>

1. Allow host driver parameter to override auto-loaded firmware (in flash).
2. Verify version of firmware that is auto-loaded from flash.
3. Change value of fw_type module parameter to reflect default firmware
   image name that is loaded by host driver (in /sys/module/liquidio/...)

 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 90 +++++++++++++++-------
 .../net/ethernet/cavium/liquidio/liquidio_image.h  |  1 +
 .../net/ethernet/cavium/liquidio/octeon_device.c   | 11 ++-
 .../net/ethernet/cavium/liquidio/octeon_device.h   | 10 +++
 4 files changed, 84 insertions(+), 28 deletions(-)

-- 
1.8.3.1
