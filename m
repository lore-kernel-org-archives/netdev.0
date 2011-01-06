From: Kelly Anderson <kelly@silka.with-linux.com>
Subject: patch ethtool 2.6.37 classificationoptions
Date: Thu, 06 Jan 2011 00:00:55 -0700
Message-ID: <4D2568A7.8040904@silka.with-linux.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040304030605080908020603"
To: bhutchings@solarflare.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 216-146-103-100.dsl.nemontel.net ([216.146.103.100]:33922 "EHLO
	silka.with-linux.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1751526Ab1AFHY1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jan 2011 02:24:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040304030605080908020603
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Attached is a fix for the missing space in classificationoptions when 
using --help.


--------------040304030605080908020603
Content-Type: text/plain;
 name="EthTool-2.6.37-fix-classificationoptions.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="EthTool-2.6.37-fix-classificationoptions.patch"

--- ./ethtool.c.orig	2010-12-16 17:37:59.000000000 -0700
+++ ./ethtool.c	2011-01-05 23:55:00.363077978 -0700
@@ -231,11 +231,11 @@ static struct option {
                 "               [ online | offline ]\n" },
     { "-S", "--statistics", MODE_GSTATS, "Show adapter statistics" },
     { "-n", "--show-nfc", MODE_GNFC, "Show Rx network flow classification"
-		"options",
+		" options",
 		"		[ rx-flow-hash tcp4|udp4|ah4|sctp4|"
 		"tcp6|udp6|ah6|sctp6 ]\n" },
     { "-f", "--flash", MODE_FLASHDEV, "FILENAME " "Flash firmware image "
-    		"from the specified file to a region on the device",
+		"from the specified file to a region on the device",
 		"               [ REGION-NUMBER-TO-FLASH ]\n" },
     { "-N", "--config-nfc", MODE_SNFC, "Configure Rx network flow "
 		"classification options",

--------------040304030605080908020603--
