From: David Miller <davem@davemloft.net>
Subject: Re: orphan sockets
Date: Fri, 08 Jul 2011 09:31:55 -0700 (PDT)
Message-ID: <20110708.093155.1103063166626789067.davem@davemloft.net>
References: <6fa7e62e85e1e2fd069aa9cbf307737a@visp.net.lb>
	<CAEnQRZDWZzCCeL3auoLJ=sK5V9yi_Zxs+HgtPoeLFRUV8b0m-Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: denys@visp.net.lb, netdev@vger.kernel.org
To: daniel.baluta@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60152 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750764Ab1GHQcI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2011 12:32:08 -0400
In-Reply-To: <CAEnQRZDWZzCCeL3auoLJ=sK5V9yi_Zxs+HgtPoeLFRUV8b0m-Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Baluta <daniel.baluta@gmail.com>
Date: Fri, 8 Jul 2011 19:28:27 +0300

> I can try to make a patch for this if you want.

No need, I'll take care of this, thanks:

--------------------
net: Fix default in docs for tcp_orphan_retries.

Default should be listed at 8 instead of 7.

Reported-by: Denys Fedoryshchenko <denys@visp.net.lb>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 Documentation/networking/ip-sysctl.txt |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index d3d653a..bfe9242 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -346,7 +346,7 @@ tcp_orphan_retries - INTEGER
 	when RTO retransmissions remain unacknowledged.
 	See tcp_retries2 for more details.
 
-	The default value is 7.
+	The default value is 8.
 	If your machine is a loaded WEB server,
 	you should think about lowering this value, such sockets
 	may consume significant resources. Cf. tcp_max_orphans.
-- 
1.7.6

