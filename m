From: Haiyang Zhang <haiyangz@exchange.microsoft.com>
Subject: [PATCH net-next,3/3] hv_netvsc: Update netvsc Document for TCP hash level setting
Date: Fri,  6 Oct 2017 08:33:59 -0700
Message-ID: <20171006153359.8400-4-haiyangz@exchange.microsoft.com>
References: <20171006153359.8400-1-haiyangz@exchange.microsoft.com>
Reply-To: haiyangz@microsoft.com
Cc: haiyangz@microsoft.com, kys@microsoft.com, sthemmin@microsoft.com,
        olaf@aepfle.de, vkuznets@redhat.com, linux-kernel@vger.kernel.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171006153359.8400-1-haiyangz@exchange.microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@microsoft.com>

Update Documentation/networking/netvsc.txt for TCP hash level setting
and related info.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
---
 Documentation/networking/netvsc.txt | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/Documentation/networking/netvsc.txt b/Documentation/networking/netvsc.txt
index 93560fb1170a..92f5b31392fa 100644
--- a/Documentation/networking/netvsc.txt
+++ b/Documentation/networking/netvsc.txt
@@ -19,12 +19,12 @@ Features
 
   Receive Side Scaling
   --------------------
-  Hyper-V supports receive side scaling. For TCP, packets are
-  distributed among available queues based on IP address and port
+  Hyper-V supports receive side scaling. For TCP & UDP, packets can
+  be distributed among available queues based on IP address and port
   number.
 
-  For UDP, we can switch UDP hash level between L3 and L4 by ethtool
-  command. UDP over IPv4 and v6 can be set differently. The default
+  For TCP & UDP, we can switch hash level between L3 and L4 by ethtool
+  command. TCP/UDP over IPv4 and v6 can be set differently. The default
   hash level is L4. We currently only allow switching TX hash level
   from within the guests.
 
-- 
2.14.1
