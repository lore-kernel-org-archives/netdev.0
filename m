From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH 0/2] drivers: net: cpsw: fix ale calls and drop host_port field from cpsw_priv
Date: Thu, 7 Apr 2016 15:16:42 +0300
Message-ID: <1460031404-28594-1-git-send-email-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
	<linux-omap@vger.kernel.org>,
	Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This clean up series intended to:
 - fix port_mask parameters in ale calls and drop unnecessary shifts
 - drop host_port field from struct cpsw_priv

Nothing critical. Tested on am437x-idk-evm in dual mac and switch modes.

Grygorii Strashko (2):
  drivers: net: cpsw: fix port_mask parameters in ale calls
  drivers: net: cpsw: drop host_port field from struct cpsw_priv

 drivers/net/ethernet/ti/cpsw.c | 52 +++++++++++++++++-------------------------
 1 file changed, 21 insertions(+), 31 deletions(-)

-- 
2.8.0
