From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] net_sched: add missing paddattr description
Date: Wed, 08 Jun 2016 06:19:45 -0700
Message-ID: <1465391985.7945.4.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:34122 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751379AbcFHNTs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 09:19:48 -0400
Received: by mail-pa0-f68.google.com with SMTP id ug1so595750pab.1
        for <netdev@vger.kernel.org>; Wed, 08 Jun 2016 06:19:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

"make htmldocs" complains otherwise:

.//net/core/gen_stats.c:65: warning: No description found for parameter 'padattr'
.//net/core/gen_stats.c:101: warning: No description found for parameter 'padattr'


Fixes: 9854518ea04d ("sched: align nlattr properly when needed")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: kbuild test robot <fengguang.wu@intel.com>
---
 net/core/gen_stats.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/core/gen_stats.c b/net/core/gen_stats.c
index f96ee8b9478d..be873e4e3125 100644
--- a/net/core/gen_stats.c
+++ b/net/core/gen_stats.c
@@ -47,6 +47,7 @@ nla_put_failure:
  * @xstats_type: TLV type for backward compatibility xstats TLV
  * @lock: statistics lock
  * @d: dumping handle
+ * @padattr: padding attribute
  *
  * Initializes the dumping handle, grabs the statistic lock and appends
  * an empty TLV header to the socket buffer for use a container for all
@@ -87,6 +88,7 @@ EXPORT_SYMBOL(gnet_stats_start_copy_compat);
  * @type: TLV type for top level statistic TLV
  * @lock: statistics lock
  * @d: dumping handle
+ * @padattr: padding attribute
  *
  * Initializes the dumping handle, grabs the statistic lock and appends
  * an empty TLV header to the socket buffer for use a container for all
