From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [PATCH net-next] sctp: kill unused macro definition
Date: Tue, 23 Nov 2010 17:00:42 +0800
Message-ID: <4CEB82BA.6030406@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org,
	Network-Maillist <netdev@vger.kernel.org>
To: Vlad Yasevich <vladislav.yasevich@hp.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:62157 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750953Ab0KWJDU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Nov 2010 04:03:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


These macros have been existed for several years since v2.6.12-rc2.
But they never be used. So remove them now.

Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
---
 include/net/sctp/constants.h |   14 --------------
 1 files changed, 0 insertions(+), 14 deletions(-)

diff --git a/include/net/sctp/constants.h b/include/net/sctp/constants.h
index 6390884..c70d8cc 100644
--- a/include/net/sctp/constants.h
+++ b/include/net/sctp/constants.h
@@ -61,7 +61,6 @@ enum { SCTP_DEFAULT_INSTREAMS = SCTP_MAX_STREAM };
  * symbols.  CIDs are dense through SCTP_CID_BASE_MAX.
  */
 #define SCTP_CID_BASE_MAX		SCTP_CID_SHUTDOWN_COMPLETE
-#define SCTP_CID_MAX			SCTP_CID_ASCONF_ACK
 
 #define SCTP_NUM_BASE_CHUNK_TYPES	(SCTP_CID_BASE_MAX + 1)
 
@@ -86,9 +85,6 @@ typedef enum {
 
 } sctp_event_t;
 
-#define SCTP_EVENT_T_MAX SCTP_EVENT_T_PRIMITIVE
-#define SCTP_EVENT_T_NUM (SCTP_EVENT_T_MAX + 1)
-
 /* As a convenience for the state machine, we append SCTP_EVENT_* and
  * SCTP_ULP_* to the list of possible chunks.
  */
@@ -162,9 +158,6 @@ SCTP_SUBTYPE_CONSTRUCTOR(PRIMITIVE,	sctp_event_primitive_t,	primitive)
 		       		- (unsigned long)(c->chunk_hdr)\
 				- sizeof(sctp_data_chunk_t)))
 
-#define SCTP_MAX_ERROR_CAUSE  SCTP_ERROR_NONEXIST_IP
-#define SCTP_NUM_ERROR_CAUSE  10
-
 /* Internal error codes */
 typedef enum {
 
@@ -266,7 +259,6 @@ enum { SCTP_ARBITRARY_COOKIE_ECHO_LEN = 200 };
 #define SCTP_TSN_MAP_INITIAL BITS_PER_LONG
 #define SCTP_TSN_MAP_INCREMENT SCTP_TSN_MAP_INITIAL
 #define SCTP_TSN_MAP_SIZE 4096
-#define SCTP_TSN_MAX_GAP  65535
 
 /* We will not record more than this many duplicate TSNs between two
  * SACKs.  The minimum PMTU is 576.  Remove all the headers and there
@@ -301,9 +293,6 @@ enum { SCTP_MAX_GABS = 16 };
 
 #define SCTP_CLOCK_GRANULARITY	1	/* 1 jiffy */
 
-#define SCTP_DEF_MAX_INIT 6
-#define SCTP_DEF_MAX_SEND 10
-
 #define SCTP_DEFAULT_COOKIE_LIFE	(60 * 1000) /* 60 seconds */
 
 #define SCTP_DEFAULT_MINWINDOW	1500	/* default minimum rwnd size */
@@ -317,9 +306,6 @@ enum { SCTP_MAX_GABS = 16 };
 					 */
 #define SCTP_DEFAULT_MINSEGMENT 512	/* MTU size ... if no mtu disc */
 #define SCTP_HOW_MANY_SECRETS 2		/* How many secrets I keep */
-#define SCTP_HOW_LONG_COOKIE_LIVE 3600	/* How many seconds the current
-					 * secret will live?
-					 */
 #define SCTP_SECRET_SIZE 32		/* Number of octets in a 256 bits. */
 
 #define SCTP_SIGNATURE_SIZE 20	        /* size of a SLA-1 signature */
-- 
1.6.3.3
