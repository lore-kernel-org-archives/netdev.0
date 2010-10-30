From: Joe Perches <joe@perches.com>
Subject: [PATCH 38/39] net/rfkill/input.c: Update WARN uses
Date: Sat, 30 Oct 2010 14:08:55 -0700
Message-ID: <7eabc1e74e9b483e921a4324d609d527fc83ec62.1288471898.git.joe@perches.com>
References: <cover.1288471897.git.joe@perches.com>
Cc: Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jiri Kosina <trivial@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:3822 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752416Ab0J3VJw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Oct 2010 17:09:52 -0400
In-Reply-To: <cover.1288471897.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Coalesce long formats.
Align arguments.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/rfkill/input.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/rfkill/input.c b/net/rfkill/input.c
index 1bca6d4..4343f59 100644
--- a/net/rfkill/input.c
+++ b/net/rfkill/input.c
@@ -75,9 +75,8 @@ static void __rfkill_handle_global_op(enum rfkill_sched_op op)
 	default:
 		/* memory corruption or bug, fail safely */
 		rfkill_epo();
-		WARN(1, "Unknown requested operation %d! "
-			"rfkill Emergency Power Off activated\n",
-			op);
+		WARN(1, "Unknown requested operation %d! rfkill Emergency Power Off activated\n",
+		     op);
 	}
 }
 
-- 
1.7.3.1.g432b3.dirty

