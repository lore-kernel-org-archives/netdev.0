From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH 03/12] headers, pppol2tp: Use __kernel_pid_t in
 <linux/pppol2tp.h>
Date: Mon, 08 Aug 2011 14:17:59 +0100
Message-ID: <1312809479.2591.1142.camel@deadeye>
References: <1312809302.2591.1139.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:50051 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751318Ab1HHNSC convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Aug 2011 09:18:02 -0400
In-Reply-To: <1312809302.2591.1139.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

<linux/types.h> defines __kernel_pid_t for userland; pid_t is
defined elsewhere (and potentially differently).

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 include/linux/if_pppol2tp.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/if_pppol2tp.h b/include/linux/if_pppol2tp.h
index 184bc55..23cefa1 100644
--- a/include/linux/if_pppol2tp.h
+++ b/include/linux/if_pppol2tp.h
@@ -39,7 +39,7 @@ struct pppol2tp_addr {
  * bits. So we need a different sockaddr structure.
  */
 struct pppol2tpv3_addr {
-	pid_t	pid;			/* pid that owns the fd.
+	__kernel_pid_t	pid;		/* pid that owns the fd.
 					 * 0 => current */
 	int	fd;			/* FD of UDP or IP socket to use */
 
-- 
1.7.5.4



