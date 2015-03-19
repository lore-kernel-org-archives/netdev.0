From: kbuild test robot <fengguang.wu@intel.com>
Subject: [jkirsher-next-queue:dev-queue 828/842]
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c:2382:5: sparse: symbol
 'mlx4_en_set_tx_maxrate' was not declared. Should it be static?
Date: Thu, 19 Mar 2015 08:51:27 +0800
Message-ID: <201503190816.FI64cKgW%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, Ido Shamay <idos@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue.git dev-queue
head:   ec59d04e8f5223083fdfb6124e8f087c1a4c5ec2
commit: c10e4fc6c45616dbadb8ccee189e2c09fb8f056f [828/842] net/mlx4_en: Add tx queue maxrate support
reproduce:
  # apt-get install sparse
  git checkout c10e4fc6c45616dbadb8ccee189e2c09fb8f056f
  make ARCH=x86_64 allmodconfig
  make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> drivers/net/ethernet/mellanox/mlx4/en_netdev.c:2382:5: sparse: symbol 'mlx4_en_set_tx_maxrate' was not declared. Should it be static?

Please review and possibly fold the followup patch.

---
0-DAY kernel test infrastructure                Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation
