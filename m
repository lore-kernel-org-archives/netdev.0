From: Denis Cheng <crquan@gmail.com>
Subject: [PATCH] net/sched: mark "NET_CLS_RSVP6 depends on IPV6"
Date: Wed,  1 Aug 2007 09:41:31 +0800
Message-ID: <11859324914084-git-send-email-crquan@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chdebra@gmail.com
To: Gabriel Craciunescu <nix.or.die@googlemail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.184]:45117 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752291AbXHABlN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jul 2007 21:41:13 -0400
Received: by rv-out-0910.google.com with SMTP id k20so44446rvb
        for <netdev@vger.kernel.org>; Tue, 31 Jul 2007 18:41:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Denis Cheng <crquan@gmail.com>
---
 net/sched/Kconfig |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index 8a74cac..5d3749c 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -300,6 +300,7 @@ config NET_CLS_RSVP
 config NET_CLS_RSVP6
 	tristate "IPv6 Resource Reservation Protocol (RSVP6)"
 	select NET_CLS
+	depends on IPV6
 	---help---
 	  The Resource Reservation Protocol (RSVP) permits end systems to
 	  request a minimum and maximum data flow rate for a connection; this
-- 
1.5.2.2

