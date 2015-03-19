From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: [PATCH net-next 2/2] net: neighbour: Document
 {mcast,ucast}_solicit, mcast_resolicit.
Date: Thu, 19 Mar 2015 22:42:04 +0900 (JST)
Message-ID: <20150319.224204.580319871687930153.yoshfuji@yoshifuji-H87MS01.miraclelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Yanjun.Zhu@windriver.com, ulf.samuelsson@ericsson.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og102.obsmtp.com ([64.18.2.157]:49059 "HELO
	exprod7og102.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1755233AbbCSNmI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 09:42:08 -0400
Received: by mail-pa0-f46.google.com with SMTP id cy3so76057895pad.3
        for <netdev@vger.kernel.org>; Thu, 19 Mar 2015 06:42:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
---
 Documentation/networking/ip-sysctl.txt | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 4412f69..6c07c2b 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1126,11 +1126,23 @@ arp_accept - BOOLEAN
 	gratuitous arp frame, the arp table will be updated regardless
 	if this setting is on or off.
 
+mcast_solicit - INTEGER
+	The maximum number of multicast probes in INCOMPLETE state,
+	when the associated hardware address is unknown.  Defaults
+	to 3.
+
+ucast_solicit - INTEGER
+	The maximum number of unicast probes in PROBE state, when
+	the hardware address is being reconfirmed.  Defaults to 3.
 
 app_solicit - INTEGER
 	The maximum number of probes to send to the user space ARP daemon
 	via netlink before dropping back to multicast probes (see
-	mcast_solicit).  Defaults to 0.
+	mcast_resolicit).  Defaults to 0.
+
+mcast_resolicit - INTEGER
+	The maximum number of multicast probes after unicast and
+	app probes in PROBE state.  Defaults to 0.
 
 disable_policy - BOOLEAN
 	Disable IPSEC policy (SPD) for this interface
-- 
1.9.1
