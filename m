From: Colin King <colin.king@canonical.com>
Subject: [PATCH] liquidio: make the spinlock octeon_devices_lock static
Date: Thu, 18 May 2017 10:14:01 +0100
Message-ID: <20170518091401.13013-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Derek Chickles <derek.chickles@caviumnetworks.com>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:52061 "EHLO
        youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754721AbdERJOD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 05:14:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin Ian King <colin.king@canonical.com>

octeon_devices_lock can be made static as it does not need to be
in global scope.

Cleans up sparse warning: "warning: symbol 'octeon_devices_lock'
was not declared. Should it be static?"

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/cavium/liquidio/octeon_device.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.c b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
index 3cc56675359a..b5be7074f3de 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
@@ -547,7 +547,7 @@ static atomic_t adapter_refcounts[MAX_OCTEON_DEVICES];
 
 static u32 octeon_device_count;
 /* locks device array (i.e. octeon_device[]) */
-spinlock_t octeon_devices_lock;
+static spinlock_t octeon_devices_lock;
 
 static struct octeon_core_setup core_setup[MAX_OCTEON_DEVICES];
 
-- 
2.11.0
