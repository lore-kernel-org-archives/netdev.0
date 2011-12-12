From: Marek Lindner <lindner_marek@yahoo.de>
Subject: [PATCH 06/11] batman-adv: readme update (mention ap isolation and new log level)
Date: Mon, 12 Dec 2011 19:31:50 +0800
Message-ID: <1323689516-24427-7-git-send-email-lindner_marek@yahoo.de>
References: <1323689516-24427-1-git-send-email-lindner_marek@yahoo.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>,
	Sven Eckelmann <sven@narfation.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm10-vm0.bullet.mail.ukl.yahoo.com ([217.146.183.242]:46557
	"HELO nm10-vm0.bullet.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752710Ab1LLLcq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2011 06:32:46 -0500
In-Reply-To: <1323689516-24427-1-git-send-email-lindner_marek@yahoo.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
---
 Documentation/networking/batman-adv.txt |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/Documentation/networking/batman-adv.txt b/Documentation/networking/batman-adv.txt
index c86d03f..221ad0c 100644
--- a/Documentation/networking/batman-adv.txt
+++ b/Documentation/networking/batman-adv.txt
@@ -200,15 +200,16 @@ abled  during run time. Following log_levels are defined:
 
 0 - All  debug  output  disabled
 1 - Enable messages related to routing / flooding / broadcasting
-2 - Enable route or tt entry added / changed / deleted
-3 - Enable all messages
+2 - Enable messages related to route added / changed / deleted
+4 - Enable messages related to translation table operations
+7 - Enable all messages
 
 The debug output can be changed at runtime  using  the  file
 /sys/class/net/bat0/mesh/log_level. e.g.
 
 # echo 2 > /sys/class/net/bat0/mesh/log_level
 
-will enable debug messages for when routes or TTs change.
+will enable debug messages for when routes change.
 
 
 BATCTL
-- 
1.7.5.4
