From: Zhu Yanjun <zyjzyj2000@gmail.com>
Subject: [PATCH 0/1] net:fec: buffer descriptor member variable order in IMX6
Date: Thu, 21 Aug 2014 17:21:54 +0800
Message-ID: <1408612915-8657-1-git-send-email-Yanjun.Zhu@windriver.com>
Cc: Zhu Yanjun <Yanjun.Zhu@windriver.com>
To: linux-kernel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, zyjzyj2000@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From Reference Manual, freescale IMX6 is little endian 
mode. Therefore the member variables in buffer 
descriptor should be length, status and so on.

Zhu Yanjun (1):
  net:fec: buffer descriptor member variable order in IMX6

 drivers/net/ethernet/freescale/fec.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

-- 
1.9.1
