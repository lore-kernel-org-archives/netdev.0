From: John Heffner <jheffner@psc.edu>
Subject: [PATCH 1/3] TCP sysctl documentation: tcp_moderate_rcvbuf
Date: Mon, 26 Feb 2007 20:09:32 -0500
Message-ID: <45E384CC.2090004@psc.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070609070202080406010206"
To: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:54929 "EHLO mailer1.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161038AbXB0BJk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Feb 2007 20:09:40 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070609070202080406010206
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


--------------070609070202080406010206
Content-Type: text/plain; x-mac-type="0"; x-mac-creator="0";
 name="doc1.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="doc1.patch"

Document sysctl tcp_moderate_rcvbuf.

Signed-off-by: John Heffner <jheffner@psc.edu>

---
commit 4c5fd9d3a9ea8b939aed1afda2ac0fc54e3df592
tree c25c2fd01e076fbb7356a8c37d06d2e22c60f263
parent aef8811abbc9249a2bd59bd2331bbe523df05d17
author John Heffner <jheffner@psc.edu> Mon, 26 Feb 2007 19:44:58 -0500
committer John Heffner <jheffner@psc.edu> Mon, 26 Feb 2007 19:44:58 -0500

 Documentation/networking/ip-sysctl.txt |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index a0f6842..a9ad96b 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -243,6 +243,12 @@ tcp_mem - vector of 3 INTEGERs: min, pressure, max
 	Defaults are calculated at boot time from amount of available
 	memory.
 
+tcp_moderate_rcvbuf - BOOLEAN
+	If set, TCP performs receive buffer autotuning, attempting to
+	automatically size the buffer (no greater than tcp_rmem[2]) to
+	match the size required by the path for full throughput.  Enabled by
+	default.
+
 tcp_orphan_retries - INTEGER
 	How may times to retry before killing TCP connection, closed
 	by our side. Default value 7 corresponds to ~50sec-16min

--------------070609070202080406010206--
