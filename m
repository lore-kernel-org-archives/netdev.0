From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net] netlink: export netlink_diag.h header
Date: Wed, 19 Jun 2013 18:06:54 -0700
Message-ID: <20130619180654.09e6a3e1@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: David Miller <davem@davemloft.net>,
	Andrey Vagin <avagin@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:36699 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934734Ab3FTBG7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 21:06:59 -0400
Received: by mail-pa0-f43.google.com with SMTP id hz11so5781347pad.16
        for <netdev@vger.kernel.org>; Wed, 19 Jun 2013 18:06:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The netlink_diag.h is in include/uapi/linux but not in the Kbuild necessary
to cause it to be exported by make headers_install.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/include/uapi/linux/Kbuild	2013-06-19 18:02:51.629893272 -0700
+++ b/include/uapi/linux/Kbuild	2013-06-19 18:03:08.329669204 -0700
@@ -261,6 +261,7 @@ header-y += net_dropmon.h
 header-y += net_tstamp.h
 header-y += netconf.h
 header-y += netdevice.h
+header-y += netlink_diag.h
 header-y += netfilter.h
 header-y += netfilter_arp.h
 header-y += netfilter_bridge.h
