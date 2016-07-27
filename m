From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build warning after merge of the net-next tree
Date: Wed, 27 Jul 2016 16:15:33 +1000
Message-ID: <20160727161533.5c5d1702@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Iyappan Subramanian <isubramanian@apm.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

After merging the net-next tree, today's linux-next build (powerpc
allyesconfig) produced this warning:

drivers/net/ethernet/apm/xgene/xgene_enet_hw.c: In function 'xgene_enet_phy_connect':
drivers/net/ethernet/apm/xgene/xgene_enet_hw.c:759:22: warning: unused variable 'adev' [-Wunused-variable]
  struct acpi_device *adev;
                      ^

Introduced by commit

  8089a96f601b ("drivers: net: xgene: Add backward compatibility")
(CONFIG_ACPI si not set for tis build)

-- 
Cheers,
Stephen Rothwell
