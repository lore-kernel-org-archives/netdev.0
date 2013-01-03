From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] ip-sysctl: fix spelling errors
Date: Thu, 3 Jan 2013 09:50:29 -0800
Message-ID: <20130103095029.40579b3f@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:58550 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753490Ab3ACRvx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Jan 2013 12:51:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/Documentation/networking/ip-sysctl.txt	2012-12-10 16:18:19.221560164 -0800
+++ b/Documentation/networking/ip-sysctl.txt	2013-01-03 09:48:53.946686658 -0800
@@ -36,7 +36,7 @@ neigh/default/unres_qlen_bytes - INTEGER
 	The maximum number of bytes which may be used by packets
 	queued for each	unresolved address by other network layers.
 	(added in linux 3.3)
-	Seting negative value is meaningless and will retrun error.
+	Setting negative value is meaningless and will return error.
 	Default: 65536 Bytes(64KB)
 
 neigh/default/unres_qlen - INTEGER
@@ -215,7 +215,7 @@ tcp_ecn - INTEGER
 	Possible values are:
 		0 Disable ECN.  Neither initiate nor accept ECN.
 		1 Always request ECN on outgoing connection attempts.
-		2 Enable ECN when requested by incomming connections
+		2 Enable ECN when requested by incoming connections
 		  but do not request ECN on outgoing connections.
 	Default: 2
 
@@ -503,7 +503,7 @@ tcp_fastopen - INTEGER
 tcp_syn_retries - INTEGER
 	Number of times initial SYNs for an active TCP connection attempt
 	will be retransmitted. Should not be higher than 255. Default value
-	is 6, which corresponds to 63seconds till the last restransmission
+	is 6, which corresponds to 63seconds till the last retransmission
 	with the current initial RTO of 1second. With this the final timeout
 	for an active TCP connection attempt will happen after 127seconds.
 
@@ -1530,7 +1530,7 @@ cookie_hmac_alg - STRING
 	* sha1
 	* none
 	Ability to assign md5 or sha1 as the selected alg is predicated on the
-	configuarion of those algorithms at build time (CONFIG_CRYPTO_MD5 and
+	configuration of those algorithms at build time (CONFIG_CRYPTO_MD5 and
 	CONFIG_CRYPTO_SHA1).
 
 	Default: Dependent on configuration.  MD5 if available, else SHA1 if
@@ -1548,7 +1548,7 @@ rcvbuf_policy - INTEGER
 	blocking.
 
 	1: rcvbuf space is per association
-	0: recbuf space is per socket
+	0: rcvbuf space is per socket
 
 	Default: 0
 
