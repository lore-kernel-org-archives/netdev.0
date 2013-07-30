From: Joe Perches <joe@perches.com>
Subject: [PATCH] ndisc: Add missing inline to ndisc_addr_option_pad
Date: Tue, 30 Jul 2013 10:31:00 -0700
Message-ID: <1375205460.2075.119.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:33272 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751584Ab3G3RbA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Jul 2013 13:31:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/net/ndisc.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/ndisc.h b/include/net/ndisc.h
index 949d775..6fea323 100644
--- a/include/net/ndisc.h
+++ b/include/net/ndisc.h
@@ -119,7 +119,7 @@ extern struct ndisc_options *ndisc_parse_options(u8 *opt, int opt_len,
  * if RFC 3831 IPv6-over-Fibre Channel is ever implemented it may
  * also need a pad of 2.
  */
-static int ndisc_addr_option_pad(unsigned short type)
+static inline int ndisc_addr_option_pad(unsigned short type)
 {
 	switch (type) {
 	case ARPHRD_INFINIBAND: return 2;
