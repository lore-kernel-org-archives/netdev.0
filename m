From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] santize tc_ematch headers
Date: Wed, 22 Aug 2007 10:18:38 -0700
Message-ID: <20070822101838.31178935@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:60459 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933770AbXHVRXn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2007 13:23:43 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The headers in tc_ematch are used by iproute2, so these headers
should be processed.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
---
 include/linux/Kbuild |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/linux/Kbuild b/include/linux/Kbuild
index ad7f71a..818cc3a 100644
--- a/include/linux/Kbuild
+++ b/include/linux/Kbuild
@@ -7,6 +7,7 @@ header-y += raid/
 header-y += spi/
 header-y += sunrpc/
 header-y += tc_act/
+header-y += tc_ematch/
 header-y += netfilter/
 header-y += netfilter_arp/
 header-y += netfilter_bridge/
-- 
1.5.2.4

