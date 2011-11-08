From: Paul Bolle <pebolle@tiscali.nl>
Subject: [PATCH] net: drivers/net/hippi/Kconfig should be sourced
Date: Tue, 08 Nov 2011 21:31:10 +0100
Message-ID: <1320784270.14409.404.camel@x61.thuisdomein>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit ff5a3b509e ("hippi: Move the HIPPI driver") moved the HIPPI
driver into drivers/net/hippi. It didn't source
drivers/net/hippi/Kconfig though, so it didn't make all necessary
Kconfig changes. So let drivers/net/kconfig source HIPPI's Kconfig file.

Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
---
git grep tested only. Perhaps the exact spot where
drivers/net/hippi/Kconfig gets sourced is relevant, so this needs
(build) testing by people actually familiar with the HIPPI driver. 

 drivers/net/Kconfig |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 583f66c..654a5e9 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -245,6 +245,8 @@ source "drivers/net/ethernet/Kconfig"
 
 source "drivers/net/fddi/Kconfig"
 
+source "drivers/net/hippi/Kconfig"
+
 config NET_SB1000
 	tristate "General Instruments Surfboard 1000"
 	depends on PNP
-- 
1.7.4.4
