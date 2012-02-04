From: Joe Perches <joe@perches.com>
Subject: [PATCH] CodingStyle: Add net and drivers/net preferred commenting
 style
Date: Sat, 04 Feb 2012 13:34:43 -0800
Message-ID: <1328391283.7008.17.camel@joe2Laptop>
References: <RE:_[PATCH]_tcp:_RST:_binding_oif_to_iif_for_tcp_v4>
	 <1328390556-14906-1-git-send-email-shawn.lu@ericsson.com>
	 <20120204.162602.1922697409850241775.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: shawn.lu@ericsson.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, xiaoclu@gmail.com,
	Randy Dunlap <rdunlap@xenotime.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:52018 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752689Ab2BDVeq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Feb 2012 16:34:46 -0500
In-Reply-To: <20120204.162602.1922697409850241775.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Perhaps adding something to CodingStyle is useful?

---

 Documentation/CodingStyle |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/Documentation/CodingStyle b/Documentation/CodingStyle
index 2b90d32..65e82e4 100644
--- a/Documentation/CodingStyle
+++ b/Documentation/CodingStyle
@@ -454,6 +454,14 @@ The preferred style for long (multi-line) comments is:
 	 * with beginning and ending almost-blank lines.
 	 */
 
+Unless the files are in net or drivers/net where David Miller
+prefers the vertically shorter:
+
+	 /* This is the preferred style for multi-line
+	  * comments in the net and drivers/net directories.
+	  * Please use it consistently.
+	  */
+
 It's also important to comment data, whether they are basic types or derived
 types.  To this end, use just one data declaration per line (no commas for
 multiple data declarations).  This leaves you room for a small comment on each
