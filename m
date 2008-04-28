From: Joakim Koskela <joakim.koskela@hiit.fi>
Subject: [PATCH] [NET] HIP IP protocol number
Date: Mon, 28 Apr 2008 15:04:01 +0300
Message-ID: <200804281504.01798.joakim.koskela@hiit.fi>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from creon.otaverkko.fi ([212.68.0.5]:55874 "EHLO creon.otaverkko.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933843AbYD1MBA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2008 08:01:00 -0400
Received: from localhost (localhost [127.0.0.1])
	by creon.otaverkko.fi (Postfix) with ESMTP id EA2FF7BC55
	for <netdev@vger.kernel.org>; Mon, 28 Apr 2008 15:00:58 +0300 (EEST)
Received: from argo.otaverkko.fi (argo.otaverkko.fi [212.68.0.2])
	by creon.otaverkko.fi (Postfix) with ESMTP id 7B17A7BC2E
	for <netdev@vger.kernel.org>; Mon, 28 Apr 2008 15:00:49 +0300 (EEST)
Received: from ip85.infrahip.net (ip85.infrahip.net [193.167.187.85])
	by argo.otaverkko.fi (Postfix) with ESMTP id 4980D25ED06
	for <netdev@vger.kernel.org>; Mon, 28 Apr 2008 15:00:49 +0300 (EEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This just adds the IP protocol number for the Host Identity Protocol
(described in RFC5201), recently assigned by the IANA.

Signed-off-by: Joakim Koskela <jookos@gmail.com>
--
diff --git a/include/linux/in.h b/include/linux/in.h
index 4065313..86a731d 100644
--- a/include/linux/in.h
+++ b/include/linux/in.h
@@ -46,6 +46,7 @@ enum {
   IPPROTO_COMP   = 108,                /* Compression Header protocol */
   IPPROTO_SCTP   = 132,		/* Stream Control Transport Protocol	*/
   IPPROTO_UDPLITE = 136,	/* UDP-Lite (RFC 3828)			*/
+  IPPROTO_HIP = 139,            /* Host Identity Protocol (RFC5201)     */
 
   IPPROTO_RAW	 = 255,		/* Raw IP packets			*/
   IPPROTO_MAX
