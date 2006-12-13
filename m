From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH 2/4][SCTP]: Enable auto loading of SCTP when creating an
	ipv6 SCTP socket.
Date: Wed, 13 Dec 2006 12:44:47 -0800
Message-ID: <1166042687.4670.11.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:46164 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750843AbWLMUpW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Dec 2006 15:45:22 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id kBDKisMl013928
	for <netdev@vger.kernel.org>; Wed, 13 Dec 2006 15:44:54 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kBDKisEi219736
	for <netdev@vger.kernel.org>; Wed, 13 Dec 2006 15:44:54 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kBDKis2O018432
	for <netdev@vger.kernel.org>; Wed, 13 Dec 2006 15:44:54 -0500
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[SCTP]: Enable auto loading of SCTP when creating an ipv6 SCTP socket.

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

---
 net/sctp/protocol.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index b61f334..3a3db56 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -1258,6 +1258,7 @@ module_exit(sctp_exit);
  * __stringify doesn't likes enums, so use IPPROTO_SCTP value (132) directly.
  */
 MODULE_ALIAS("net-pf-" __stringify(PF_INET) "-proto-132");
+MODULE_ALIAS("net-pf-" __stringify(PF_INET6) "-proto-132");
 MODULE_AUTHOR("Linux Kernel SCTP developers <lksctp-developers@lists.sourceforge.net>");
 MODULE_DESCRIPTION("Support for the SCTP protocol (RFC2960)");
 MODULE_LICENSE("GPL");


