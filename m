From: Krister Johansen <kjlx@templeofstupid.com>
Subject: [PATCH iproute/master 1/3] iptunnel: document mode parameter for sit tunnels
Date: Fri,  9 Jun 2017 18:31:30 -0700
Message-ID: <1497058292-10099-2-git-send-email-kjlx@templeofstupid.com>
References: <1497058292-10099-1-git-send-email-kjlx@templeofstupid.com>
Cc: netdev@vger.kernel.org, simon.horman@netronome.com,
        dsahern@gmail.com, Krister Johansen <kjlx@templeofstupid.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sub5.mail.dreamhost.com ([208.113.200.129]:56398 "EHLO
        homiemail-a48.g.dreamhost.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751608AbdFJBcR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 21:32:17 -0400
Received: from homiemail-a48.g.dreamhost.com (localhost [127.0.0.1])
        by homiemail-a48.g.dreamhost.com (Postfix) with ESMTP id C540E70D2B11
        for <netdev@vger.kernel.org>; Fri,  9 Jun 2017 18:32:16 -0700 (PDT)
Received: from kmjvbox (c-174-62-91-145.hsd1.ca.comcast.net [174.62.91.145])
        (using TLSv1 with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
        (No client certificate requested)
        (Authenticated sender: kjlx@templeofstupid.com)
        by homiemail-a48.g.dreamhost.com (Postfix) with ESMTPSA id 9FCAB70D2B0C
        for <netdev@vger.kernel.org>; Fri,  9 Jun 2017 18:32:16 -0700 (PDT)
In-Reply-To: <1497058292-10099-1-git-send-email-kjlx@templeofstupid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Original-Author: Simon Horman <simon.horman@netronome.com>
Signed-off-by: Krister Johansen <kjlx@templeofstupid.com>
---
 man/man8/ip-link.8.in | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 5d73538..3cc2f5d 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -660,7 +660,9 @@ the following additional arguments are supported:
 ] [
 .RB [ no ] encap-csum
 ] [
-.RB [ no ] encap-remcsum
+.I " [no]encap-remcsum "
+] [
+.I " mode " { ip6ip | ipip | any } "
 ]
 
 .in +8
@@ -697,6 +699,12 @@ encapsulation.
 - specifies if Remote Checksum Offload is enabled. This is only
 applicable for Generic UDP Encapsulation.
 
+.sp
+.BI mode " { ip6ip | ipip | any } "
+- specifies mode in which device should run. "ip6ip" indicates
+IPv6-Over-IPv4, "ipip" indicates "IPv4-Over-IPv4", "any" indicates either
+IPv6 or IPv4 Over IPv4. Only supported for SIT where the default is "ip6ip".
+
 .in -8
 
 .TP
-- 
2.7.4
