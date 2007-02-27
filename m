From: John Heffner <jheffner@psc.edu>
Subject: [PATCH 2/3] TCP sysctl documentation: tcp_no_metrics_save
Date: Mon, 26 Feb 2007 20:09:34 -0500
Message-ID: <45E384CE.7030209@psc.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020500050800060005030809"
To: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:54928 "EHLO mailer1.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161041AbXB0BJl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Feb 2007 20:09:41 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020500050800060005030809
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


--------------020500050800060005030809
Content-Type: text/plain; x-mac-type="0"; x-mac-creator="0";
 name="doc2.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="doc2.patch"

Document sysctl tcp_no_metrics_save.

Signed-off-by: John Heffner <jheffner@psc.edu>

---
commit 17cb799000caef3b2fed28cc5d0601bb2311efa8
tree c27ccf561065b145bc48d0b8dbbaa3c608015e03
parent 4c5fd9d3a9ea8b939aed1afda2ac0fc54e3df592
author John Heffner <jheffner@psc.edu> Mon, 26 Feb 2007 19:51:50 -0500
committer John Heffner <jheffner@psc.edu> Mon, 26 Feb 2007 19:51:50 -0500

 Documentation/networking/ip-sysctl.txt |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index a9ad96b..891f389 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -249,6 +249,14 @@ tcp_moderate_rcvbuf - BOOLEAN
 	match the size required by the path for full throughput.  Enabled by
 	default.
 
+tcp_no_metrics_save - BOOLEAN
+	By default, TCP saves various connection metrics in the route cache
+	when the connection closes, so that connections established in the
+	near future can use these to set initial conditions.  Usually, this
+	increases overall performance, but may sometimes cause performance
+	degredation.  If set, TCP will not cache metrics on closing
+	connections.
+
 tcp_orphan_retries - INTEGER
 	How may times to retry before killing TCP connection, closed
 	by our side. Default value 7 corresponds to ~50sec-16min

--------------020500050800060005030809--
