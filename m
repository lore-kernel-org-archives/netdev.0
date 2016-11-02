From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH net-next v2] mlxsw: Remove unused including <generated/utsrelease.h>
Date: Wed,  2 Nov 2016 12:49:57 +0000
Message-ID: <1478090997-15020-1-git-send-email-weiyj.lk@gmail.com>
References: <1478013248-9409-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org
To: Jiri Pirko <jiri@mellanox.com>, Ido Schimmel <idosch@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35418 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752483AbcKBMxD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 08:53:03 -0400
Received: by mail-pf0-f193.google.com with SMTP id i88so1733573pfk.2
        for <netdev@vger.kernel.org>; Wed, 02 Nov 2016 05:53:02 -0700 (PDT)
In-Reply-To: <1478013248-9409-1-git-send-email-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

Remove including <generated/utsrelease.h> that don't need it.

Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
v1 -> v2: remove from spectrum.c and switchx2.c
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 1 -
 drivers/net/ethernet/mellanox/mlxsw/switchib.c | 1 -
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c | 1 -
 3 files changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 8bca020..a5433e4 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -54,7 +54,6 @@
 #include <linux/dcbnl.h>
 #include <linux/inetdevice.h>
 #include <net/switchdev.h>
-#include <generated/utsrelease.h>
 #include <net/pkt_cls.h>
 #include <net/tc_act/tc_mirred.h>
 #include <net/netevent.h>
diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchib.c b/drivers/net/ethernet/mellanox/mlxsw/switchib.c
index ec0b27e..1552594 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/switchib.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/switchib.c
@@ -43,7 +43,6 @@
 #include <linux/skbuff.h>
 #include <linux/if_vlan.h>
 #include <net/switchdev.h>
-#include <generated/utsrelease.h>
 
 #include "pci.h"
 #include "core.h"
diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
index 5208764..60f19fb 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
@@ -45,7 +45,6 @@
 #include <linux/skbuff.h>
 #include <linux/if_vlan.h>
 #include <net/switchdev.h>
-#include <generated/utsrelease.h>
 
 #include "pci.h"
 #include "core.h"
