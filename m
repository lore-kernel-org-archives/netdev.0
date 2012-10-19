From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 13/21] Documentation: networking: Convert is_<foo>_ether_addr uses to eth_addr_<foo>
Date: Thu, 18 Oct 2012 21:14:57 -0700
Message-ID: <a5d3882636abe2d2d5a05b0bbb11eeae3b143d79.1350618011.git.joe@perches.com>
References: <cover.1350618006.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1350618006.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert the old ether_addr tests to eth_addr_<foo>.
Adds api consistency.

Signed-off-by: Joe Perches <joe@perches.com>
---
 Documentation/networking/driver.txt |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/Documentation/networking/driver.txt b/Documentation/networking/driver.txt
index da59e28..4db39f4 100644
--- a/Documentation/networking/driver.txt
+++ b/Documentation/networking/driver.txt
@@ -80,7 +80,7 @@ Probing guidelines:
 
 1) Any hardware layer address you obtain for your device should
    be verified.  For example, for ethernet check it with
-   linux/etherdevice.h:is_valid_ether_addr()
+   linux/etherdevice.h:eth_addr_valid()
 
 Close/stop guidelines:
 
-- 
1.7.8.111.gad25c.dirty
