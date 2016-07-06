From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC iproute2 1/3] iptunnel: document mode parameter for sit tunnels
Date: Wed,  6 Jul 2016 20:23:16 +0200
Message-ID: <1467829398-4601-2-git-send-email-simon.horman@netronome.com>
References: <1467829398-4601-1-git-send-email-simon.horman@netronome.com>
Cc: stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:36290 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755291AbcGFSX2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2016 14:23:28 -0400
Received: by mail-wm0-f50.google.com with SMTP id f126so183600109wma.1
        for <netdev@vger.kernel.org>; Wed, 06 Jul 2016 11:23:28 -0700 (PDT)
In-Reply-To: <1467829398-4601-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 man/man8/ip-link.8.in | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 375b4d081408..822cf1bbd5f1 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -605,6 +605,8 @@ the following additional arguments are supported:
 .I " [no]encap-csum "
 ] [
 .I " [no]encap-remcsum "
+] [
+.I " mode " { ip6ip | ipip | any } "
 ]
 
 .in +8
@@ -641,6 +643,12 @@ encapsulation.
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
2.7.0.rc3.207.g0ac5344
