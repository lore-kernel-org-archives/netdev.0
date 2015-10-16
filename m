From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] uapi: add mpls_iptunnel.h
Date: Fri, 16 Oct 2015 16:12:34 -0700
Message-ID: <20151016161234.1ad0c9db@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:36343 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751103AbbJPXNa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 19:13:30 -0400
Received: by pacfv9 with SMTP id fv9so35014510pac.3
        for <netdev@vger.kernel.org>; Fri, 16 Oct 2015 16:13:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add missing rule to export mpls iptunnel header needed by iproute2

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/include/uapi/linux/Kbuild	2015-10-12 08:26:44.745317580 -0700
+++ b/include/uapi/linux/Kbuild	2015-10-16 16:09:39.362933576 -0700
@@ -263,6 +263,7 @@ header-y += minix_fs.h
 header-y += mman.h
 header-y += mmtimer.h
 header-y += mpls.h
+header-y += mpls_iptunnel.h
 header-y += mqueue.h
 header-y += mroute6.h
 header-y += mroute.h
