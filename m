From: Stafford Horne <shorne@gmail.com>
Subject: [PATCH 1/2] libceph: Remove unneeded stddef.h include
Date: Sun,  5 Feb 2017 16:07:32 +0900
Message-ID: <b49a86823ae528ff795c8931f68392535b0fccf7.1486276931.git.shorne@gmail.com>
References: <cover.1486276931.git.shorne@gmail.com>
Cc: Stafford Horne <shorne@gmail.com>,
        Ilya Dryomov <idryomov@gmail.com>,
        "Yan, Zheng" <zyan@redhat.com>, Sage Weil <sage@redhat.com>,
        "David S. Miller" <davem@davemloft.net>,
        ceph-devel@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <ceph-devel-owner@vger.kernel.org>
In-Reply-To: <cover.1486276931.git.shorne@gmail.com>
In-Reply-To: <cover.1486276931.git.shorne@gmail.com>
References: <cover.1486276931.git.shorne@gmail.com>
Sender: ceph-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This was causing a build failure for openrisc when using musl and
gcc 5.4.0 since the file is not available in the toolchain.

It doesnt seem this is needed and removing it does not cause any build
warnings for me.

Signed-off-by: Stafford Horne <shorne@gmail.com>
---
 net/ceph/snapshot.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/ceph/snapshot.c b/net/ceph/snapshot.c
index 154683f..705414e 100644
--- a/net/ceph/snapshot.c
+++ b/net/ceph/snapshot.c
@@ -18,8 +18,6 @@
  * 02110-1301, USA.
  */
 
-#include <stddef.h>
-
 #include <linux/types.h>
 #include <linux/export.h>
 #include <linux/ceph/libceph.h>
-- 
2.9.3

