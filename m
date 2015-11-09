From: Niklas Cassel <niklas.cassel@axis.com>
Subject: [PATCH RESEND] net: Documentation: Fix default value tcp_limit_output_bytes
Date: Mon, 9 Nov 2015 15:59:00 +0100
Message-ID: <1447081140-16955-1-git-send-email-niklass@axis.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <kuznet@ms2.inr.ac.ru>,
	<jmorris@namei.org>, <yoshfuji@linux-ipv6.org>, <kaber@trash.net>,
	Niklas Cassel <niklass@axis.com>,
	Niklas Cassel <niklass@axis.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bes.se.axis.com ([195.60.68.10]:55204 "EHLO bes.se.axis.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750855AbbKIO7P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Nov 2015 09:59:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit c39c4c6abb89 ("tcp: double default TSQ output bytes limit")
updated default value for tcp_limit_output_bytes

Signed-off-by: Niklas Cassel <niklas.cassel@axis.com>
---
Already sent the patch to linux-doc@vger.kernel.org,
but sending it to netdev@vger.kernel.org too.

 Documentation/networking/ip-sysctl.txt | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 05915be..2ea4c45 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -709,7 +709,7 @@ tcp_limit_output_bytes - INTEGER
 	typical pfifo_fast qdiscs.
 	tcp_limit_output_bytes limits the number of bytes on qdisc
 	or device to reduce artificial RTT/cwnd and reduce bufferbloat.
-	Default: 131072
+	Default: 262144
 
 tcp_challenge_ack_limit - INTEGER
 	Limits number of Challenge ACK sent per second, as recommended
-- 
2.1.4
