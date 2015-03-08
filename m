From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] neterion:  remove reference to ifconfig
Date: Sun, 8 Mar 2015 11:48:49 -0700
Message-ID: <20150308114849.6423e5b7@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jon Mason <jdmason@kudzu.us>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:42254 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932080AbbCHSsw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Mar 2015 14:48:52 -0400
Received: by padfa1 with SMTP id fa1so66815253pad.9
        for <netdev@vger.kernel.org>; Sun, 08 Mar 2015 11:48:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove reference to obsolete ifconfig command.
MTU can be changed with ip command instead.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/Documentation/networking/s2io.txt	2014-02-12 08:21:53.307906588 -0800
+++ b/Documentation/networking/s2io.txt	2015-03-08 11:45:41.782207739 -0700
@@ -38,7 +38,7 @@ The corresponding adapter's LED will bli
 
 3.	Features supported:
 a. Jumbo frames. Xframe I/II supports MTU up to 9600 bytes,
-modifiable using ifconfig command.
+modifiable using ip command.
 
 b. Offloads. Supports checksum offload(TCP/UDP/IP) on transmit
 and receive, TSO.
--- a/Documentation/networking/vxge.txt	2014-02-12 08:21:53.309906559 -0800
+++ b/Documentation/networking/vxge.txt	2015-03-08 11:46:01.494299026 -0700
@@ -39,7 +39,7 @@ iii) PCI-SIG's I/O Virtualization
 
 iv)  Jumbo frames
        X3100 Series supports MTU up to 9600 bytes, modifiable using
-       ifconfig command.
+       ip command.
 
 v)   Offloads supported: (Enabled by default)
        Checksum offload (TCP/UDP/IP) on transmit and receive paths
