From: H Hartley Sweeten <hartleys@visionengravers.com>
Subject: [PATCH] NFC: netlink.c: local variables should not be exposed globally
Date: Thu, 26 Apr 2012 11:09:12 -0700
Message-ID: <201204261109.13120.hartleys@visionengravers.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-wireless@vger.kernel.org>,
	<lauro.venancio@openbossa.org>, <aloisio.almeida@openbossa.org>,
	<sameo@linux.intel.com>, <davem@davemloft.net>
To: Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail127.messagelabs.com ([216.82.250.115]:26369 "EHLO
	mail127.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757033Ab2DZSJ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 14:09:26 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The variable ''nfc_genl_family' is only referenced in this file and
should be marked static to prevent it from being exposed globally.

Quites the sparse warning:

warning: symbol 'nfc_genl_family' was not declared. Should it be static?

Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
Cc: Lauro Ramos Venancio <lauro.venancio@openbossa.org>
Cc: Aloisio Almeida Jr <aloisio.almeida@openbossa.org>
Cc: Samuel Ortiz <sameo@linux.intel.com>
Cc: "David S. Miller" <davem@davemloft.net>

---

diff --git a/net/nfc/netlink.c b/net/nfc/netlink.c
index f1829f6..850485d 100644
--- a/net/nfc/netlink.c
+++ b/net/nfc/netlink.c
@@ -33,7 +33,7 @@ static struct genl_multicast_group nfc_genl_event_mcgrp = {
 	.name = NFC_GENL_MCAST_EVENT_NAME,
 };
 
-struct genl_family nfc_genl_family = {
+static struct genl_family nfc_genl_family = {
 	.id = GENL_ID_GENERATE,
 	.hdrsize = 0,
 	.name = NFC_GENL_NAME,
