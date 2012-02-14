From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [RFC iproute 2/2] iproute2: Update ip-link manpage for new option to
 set VF privileges
Date: Tue, 14 Feb 2012 13:26:39 -0600
Message-ID: <20120214192639.GA14484@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:31047 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757134Ab2BNT1E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2012 14:27:04 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 man/man8/ip-link.8 |   41 +++++++++++++++++++++++++++++++++++++++++
 1 files changed, 41 insertions(+), 0 deletions(-)

diff --git a/man/man8/ip-link.8 b/man/man8/ip-link.8
index 8c63584..874b749 100644
--- a/man/man8/ip-link.8
+++ b/man/man8/ip-link.8
@@ -98,6 +98,9 @@ ip-link \- network device configuration
 .B rate
 .IR TXRATE " ] ["
 .B spoofchk { on | off }
+] [
+.B privilege
+.IR PRIVILEGE
 ] |
 .br
 .B master
@@ -305,6 +308,44 @@ parameter must be specified.
 .sp
 .BI spoofchk " on|off"
 - turn packet spoof checking on or off for the specified VF.
+
+.sp
+.BI privilege " PRIVILEGE"
+- change the privilege level for the specified VF. The argument to this option
+is a hexadecimal value using one or a combination of the following privilege
+categories :
+.br
+.in +8
+.B 0x1
+Default privileges. Local access only.
+.br
+.B 0x2
+Privilege to gather statistics.
+.br
+.B 0x4
+Privilege to manage link parameters.
+.br
+.B 0x8
+Privilege to perform diagnostics.
+.br
+.B 0x10
+Privilege to change MAC address.
+.br
+.B 0x20
+Privilege to add or remove VLANs.
+.br
+.B 0x40
+Unrestricted administrative access privileges to everything except access to
+secure content.
+.br
+.B 0x80
+Privilege to access secure content like debug resisters.
+.br
+.in -8
+.br
+The
+.B vf
+parameter must be specified.
 .in -8
 
 .TP
-- 
1.7.1
