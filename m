From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 13/20] man: ip-ntable.8: Review synopsis section
Date: Wed,  2 Mar 2016 19:20:01 +0100
Message-ID: <1456942808-15946-14-git-send-email-phil@nwl.cc>
References: <20160302093800.7e7dbe71@xeon-e3>
 <1456942808-15946-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:33861 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756415AbcCBSW0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2016 13:22:26 -0500
In-Reply-To: <1456942808-15946-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The first line contained a c'n'p error, incorrectly listing 'ip address'
syntax. Since PARAMS is used just once and there are not many other
parameters to 'ip ntable change', state them inline and in addition to
that clarify the possibility to pass multiple parameters at once.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/ip-ntable.8 | 39 ++++++++++++++++++++++-----------------
 1 file changed, 22 insertions(+), 17 deletions(-)

diff --git a/man/man8/ip-ntable.8 b/man/man8/ip-ntable.8
index 462e5896b6482..4f0f2e548a21e 100644
--- a/man/man8/ip-ntable.8
+++ b/man/man8/ip-ntable.8
@@ -8,7 +8,7 @@ ip-ntable - neighbour table configuration
 .ti -8
 .B ip
 .RI "[ " OPTIONS " ]"
-.B address
+.B ntable
 .RI " { " COMMAND " | "
 .BR help " }"
 .sp
@@ -17,34 +17,39 @@ ip-ntable - neighbour table configuration
 .BR "ip ntable change name"
 .IR NAME " [ "
 .B dev
-.IR DEV " ] " PARMS
-
-.ti -8
-.IR PARMS " := { "
+.IR DEV " ] ["
 .B thresh1
-.IR VAL " | "
+.IR VAL " ] ["
 .B thresh2
-.IR VAL " | "
+.IR VAL " ] ["
 .B thresh3
-.IR VAL " | "
+.IR VAL " ] ["
 .B gc_int
-.IR MSEC " | "
+.IR MSEC " ] ["
 .B base_reachable
-.IR MSEC " | "
+.IR MSEC " ] ["
 .B retrans
-.IR MSEC " | " "gc_stale MSEC " " | "
+.IR MSEC " ] ["
+.B gc_stale
+.IR MSEC " ] ["
 .B delay_probe
-.IR MSEC " | " "queue LEN " " | "
+.IR MSEC " ] ["
+.B queue
+.IR LEN " ] ["
 .B app_probs
-.IR VAL " | "
+.IR VAL " ] ["
 .B ucast_probes
-.IR VAL " | " "mcast_probes VAL " " | "
+.IR VAL " ] ["
+.B mcast_probes
+.IR VAL " ] ["
 .B anycast_delay
-.IR MSEC " | "
+.IR MSEC " ] ["
 .B proxy_delay
-.IR MSEC " | " "proxy_queue LEN " " | "
+.IR MSEC " ] ["
+.B proxy_queue
+.IR LEN " ] ["
 .B locktime
-.IR MSEC " }"
+.IR MSEC " ]"
 
 .ti -8
 .BR "ip ntable show" " [ "
-- 
2.7.2
