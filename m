From: Brian Haley <brian.haley@hp.com>
Subject: [PATCH] change sctp globals to __read_mostly
Date: Fri, 01 Sep 2006 11:31:52 -0400
Message-ID: <44F85268.2060907@hp.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050906080408010300080103"
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:46738 "EHLO atlrel8.hp.com")
	by vger.kernel.org with ESMTP id S1751570AbWIAPbx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2006 11:31:53 -0400
To: david Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050906080408010300080103
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Change sctp globals to __read_mostly.

Signed-off-by: Brian Haley <brian.haley@hp.com>

--------------050906080408010300080103
Content-Type: text/x-patch;
 name="sctp.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="sctp.patch"

diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 5692ef5..d9dd4c4 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -61,7 +61,7 @@
 #include <net/inet_ecn.h>
 
 /* Global data structures. */
-struct sctp_globals sctp_globals;
+struct sctp_globals sctp_globals __read_mostly;
 struct proc_dir_entry	*proc_net_sctp;
 DEFINE_SNMP_STAT(struct sctp_mib, sctp_statistics) __read_mostly;
 

--------------050906080408010300080103--
