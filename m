From: Chris Packham <chris.packham@alliedtelesis.co.nz>
Subject: [PATCH] switchdev: documentation: minor typo fixes
Date: Mon, 21 Aug 2017 08:52:54 +1200
Message-ID: <20170820205255.29382-1-chris.packham@alliedtelesis.co.nz>
Cc: corbet@lwn.net, linux-doc@vger.kernel.org,
        Chris Packham <chris.packham@alliedtelesis.co.nz>,
        linux-kernel@vger.kernel.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Two typos in switchdev.txt

Signed-off-by: Chris Packham <chris.packham@alliedtelesis.co.nz>
---
 Documentation/networking/switchdev.txt | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/Documentation/networking/switchdev.txt b/Documentation/networking/switchdev.txt
index 3e7b946dea27..5e40e1f68873 100644
--- a/Documentation/networking/switchdev.txt
+++ b/Documentation/networking/switchdev.txt
@@ -228,7 +228,7 @@ Learning on the device port should be enabled, as well as learning_sync:
 	bridge link set dev DEV learning on self
 	bridge link set dev DEV learning_sync on self
 
-Learning_sync attribute enables syncing of the learned/forgotton FDB entry to
+Learning_sync attribute enables syncing of the learned/forgotten FDB entry to
 the bridge's FDB.  It's possible, but not optimal, to enable learning on the
 device port and on the bridge port, and disable learning_sync.
 
@@ -245,7 +245,7 @@ the responsibility of the port driver/device to age out these entries.  If the
 port device supports ageing, when the FDB entry expires, it will notify the
 driver which in turn will notify the bridge with SWITCHDEV_FDB_DEL.  If the
 device does not support ageing, the driver can simulate ageing using a
-garbage collection timer to monitor FBD entries.  Expired entries will be
+garbage collection timer to monitor FDB entries.  Expired entries will be
 notified to the bridge using SWITCHDEV_FDB_DEL.  See rocker driver for
 example of driver running ageing timer.
 
-- 
2.14.1
