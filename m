From: Olaf Hering <olh@suse.de>
Subject: [PATCH 71/82] remove linux/version.h from include/linux/if_wanpipe_common.h
Date: Sun, 10 Jul 2005 19:36:19 +0000
Message-ID: <44263.2170430899$1121024446@news.gmane.org>
References: <20050710193508.0.PmFpst2252.2247.olh@nectarine.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20050710193508.0.PmFpst2252.2247.olh@nectarine.suse.de>  
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


changing CONFIG_LOCALVERSION rebuilds too much, for no appearent reason.

Signed-off-by: Olaf Hering <olh@suse.de>

include/linux/if_wanpipe_common.h |    2 --
1 files changed, 2 deletions(-)

Index: linux-2.6.13-rc2-mm1/include/linux/if_wanpipe_common.h
===================================================================
--- linux-2.6.13-rc2-mm1.orig/include/linux/if_wanpipe_common.h
+++ linux-2.6.13-rc2-mm1/include/linux/if_wanpipe_common.h
@@ -17,8 +17,6 @@
#ifndef _WANPIPE_SOCK_DRIVER_COMMON_H
#define _WANPIPE_SOCK_DRIVER_COMMON_H

-#include <linux/version.h>
-
typedef struct {
struct net_device *slave;
atomic_t packet_sent;
