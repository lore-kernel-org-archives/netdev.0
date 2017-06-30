From: Matteo Croce <mcroce@redhat.com>
Subject: [PATCH v2] Documentation: fix wrong example command
Date: Fri, 30 Jun 2017 18:21:47 +0200
Message-ID: <20170630162147.12369-1-mcroce@redhat.com>
Cc: linux-doc@vger.kernel.org, davem@davemloft.net,
        Matteo Croce <mcroce@redhat.com>
To: netdev@vger.kernel.org
Return-path: <linux-doc-owner@vger.kernel.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In the IPVLAN documentation there is an example command line where the
master and slave interface names are inverted.
Fix the command line and also add the optional `name' keyword to better
describe what the command is doing.

v2: added commit message

Signed-off-by: Matteo Croce <mcroce@redhat.com>
---
 Documentation/networking/ipvlan.txt | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/Documentation/networking/ipvlan.txt b/Documentation/networking/ipvlan.txt
index 24196ce..1fe42a8 100644
--- a/Documentation/networking/ipvlan.txt
+++ b/Documentation/networking/ipvlan.txt
@@ -22,9 +22,9 @@ The driver can be built into the kernel (CONFIG_IPVLAN=y) or as a module
 	There are no module parameters for this driver and it can be configured
 using IProute2/ip utility.
 
-	ip link add link <master-dev> <slave-dev> type ipvlan mode { l2 | l3 | l3s }
+	ip link add link <master-dev> name <slave-dev> type ipvlan mode { l2 | l3 | l3s }
 
-	e.g. ip link add link ipvl0 eth0 type ipvlan mode l2
+	e.g. ip link add link eth0 name ipvl0 type ipvlan mode l2
 
 
 4. Operating modes:
-- 
2.9.4

