From: kbuild test robot <lkp@intel.com>
Subject: [RFC PATCH] net: encx24j600_exit() can be static
Date: Thu, 1 Oct 2015 20:26:20 +0800
Message-ID: <20151001122620.GA9861@xian>
References: <201510012040.yAkBkB49%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, broonie@kernel.org, gregkh@linuxfoundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Jon Ringle <jringle@gridpoint.com>
To: jon@ringle.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1443699801-8888-2-git-send-email-jon@ringle.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 encx24j600.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/microchip/encx24j600.c b/drivers/net/ethernet/microchip/encx24j600.c
index 1da37fd..afc008a 100644
--- a/drivers/net/ethernet/microchip/encx24j600.c
+++ b/drivers/net/ethernet/microchip/encx24j600.c
@@ -1112,7 +1112,7 @@ static int __init encx24j600_init(void)
 }
 module_init(encx24j600_init);
 
-void encx24j600_exit(void)
+static void encx24j600_exit(void)
 {
 	spi_unregister_driver(&encx24j600_spi_net_driver);
 }
