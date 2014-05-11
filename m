From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH iproute2] Document VF link state control in the ip-link man page
Date: Sun, 11 May 2014 09:22:19 +0300
Message-ID: <1399789339-29259-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, ronye@mellanox.com, amirv@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:35078 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754825AbaEKGWZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 May 2014 02:22:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Document the support added by commit 07fa9c1 "Add VF link state
control" in the ip-link man page.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 man/man8/ip-link.8.in |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 94d07fc..f295fe3 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -124,7 +124,8 @@ ip-link \- network device configuration
 .IR VLAN-QOS " ] ] ["
 .B rate
 .IR TXRATE " ] ["
-.B spoofchk { on | off }
+.B spoofchk { on | off } ] [ 
+.B state { auto | enable | disable}
 ] |
 .br
 .B master
@@ -576,6 +577,12 @@ parameter must be specified.
 .sp
 .BI spoofchk " on|off"
 - turn packet spoof checking on or off for the specified VF.
+.sp
+.BI state " auto|enable|disable"
+- set the virtual link state as seen by the specified VF. Setting to auto means a 
+reflection of the PF link state, enable lets the VF to communicate with other VFs on 
+this host even if the PF link state is down, disable causes the HW to drop any packets 
+sent by the VF.
 .in -8
 
 .TP
-- 
1.7.1
