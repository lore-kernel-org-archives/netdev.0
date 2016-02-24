From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 16/20] man: ip-tunnel.8: Document missing 6rd action
Date: Wed, 24 Feb 2016 09:21:29 +0100
Message-ID: <1456302093-697-17-git-send-email-phil@nwl.cc>
References: <1456302093-697-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:51153 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758117AbcBXIWX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Feb 2016 03:22:23 -0500
In-Reply-To: <1456302093-697-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also drop the non-terminal 'TIME' description as it is not referenced
anywhere.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/ip-tunnel.8 | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/man/man8/ip-tunnel.8 b/man/man8/ip-tunnel.8
index 8b746cb0f52b8..4938c7405ce85 100644
--- a/man/man8/ip-tunnel.8
+++ b/man/man8/ip-tunnel.8
@@ -11,7 +11,7 @@ ip-tunnel - tunnel configuration
 .ti -8
 .BR "ip "
 .RI "[ " OPTIONS " ]"
-.BR "tunnel" " { " add " | " change " | " del " | " show " | " prl " }"
+.BR "tunnel" " { " add " | " change " | " del " | " show " | " prl " | " 6rd " }"
 .RI "[ " NAME " ]"
 .br
 .RB "[ " mode
@@ -42,6 +42,12 @@ ip-tunnel - tunnel configuration
 .B prl-delete
 .IR ADDR " ]"
 .br
+.RB "[ " 6rd-prefix
+.IR ADDR " ] ["
+.B 6rd-relay_prefix
+.IR ADDR " ] [
+.BR 6rd-reset " ]"
+.br
 .RB "[ [" no "]" pmtudisc " ]"
 .RB "[ " dev
 .IR PHYS_DEV " ]"
@@ -75,9 +81,6 @@ ip-tunnel - tunnel configuration
 .ti -8
 .IR KEY " := { " DOTTED_QUAD " | " NUMBER " }"
 
-.ti -8
-.IR TIME " := " NUMBER "[s|ms]"
-
 .SH DESCRIPTION
 .B tunnel
 objects are tunnels, encapsulating packets in IP packets and then
-- 
2.6.4
