From: kbuild test robot <fengguang.wu@intel.com>
Subject: [PATCH net-next] be2net: be_hwmon_show_temp() can be static
Date: Fri, 15 May 2015 03:02:35 +0800
Message-ID: <20150514190234.GA103883@snb>
References: <201505150315.NZBccr7Q%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, Sathya Perla <sathya.perla@avagotech.com>,
	Ajit Khaparde <ajit.khaparde@avagotech.com>,
	Padmanabh Ratnakar <padmanabh.ratnakar@avagotech.com>,
	Sriharsha Basavapatna <sriharsha.basavapatna@avagotech.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Ying Xue <ying.xue@windriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201505150315.NZBccr7Q%fengguang.wu@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 be_main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index dc7c0fd..76d491f 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -5612,7 +5612,7 @@ static void be_remove(struct pci_dev *pdev)
 	free_netdev(adapter->netdev);
 }
 
-ssize_t be_hwmon_show_temp(struct device *dev,
+static ssize_t be_hwmon_show_temp(struct device *dev,
 			   struct device_attribute *dev_attr,
 			   char *buf)
 {
