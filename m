From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH] man: ip-link: Document query_rss option
Date: Fri, 10 Jun 2016 16:39:50 +0200
Message-ID: <1465569590-2983-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:39176 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932099AbcFJOkE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jun 2016 10:40:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Doc text shamelessly stolen from the introducing commit's message
(6c55c8c4617c5 ['ip link set vf: Added "query_rss" command']).

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/ip-link.8.in | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 8fcce5e53f6ac..d5673639d9ddf 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -141,6 +141,8 @@ ip-link \- network device configuration
 .br
 .RB "[ " spoofchk " { " on " | " off " } ]"
 .br
+.RB "[ " query_rss " { " on " | " off " } ]"
+.br
 .RB "[ " state " { " auto " | " enable " | " disable " } ]"
 .br
 .RB "[ " trust " { " on " | " off " } ] ]"
@@ -1159,6 +1161,9 @@ parameter must be specified.
 .BI spoofchk " on|off"
 - turn packet spoof checking on or off for the specified VF.
 .sp
+.BI query_rss " on|off"
+- toggle the ability of querying the RSS configuration of a specific VF. VF RSS information like RSS hash key may be considered sensitive on some devices where this information is shared between VF and PF and thus its querying may be prohibited by default.
+.sp
 .BI state " auto|enable|disable"
 - set the virtual link state as seen by the specified VF. Setting to auto means a
 reflection of the PF link state, enable lets the VF to communicate with other VFs on
-- 
2.8.2
