From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: [PATCH 0/8] r8169 patches for net-next v2
Date: Thu, 21 Oct 2010 10:25:35 +0200
Message-ID: <1287649543-6569-1-git-send-email-sgruszka@redhat.com>
Cc: Denis Kirjanov <kirjanov@gmail.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>
To: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53249 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753163Ab0JUIXU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Oct 2010 04:23:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v1 -> v2
- update to current code and some minor changes/cleanups
- do not return NETDEV_TX_BUSY from start_xmit when mapping fail (patch 1)
- add missing unlikely (patch 1)
- account tx bytes based on skb->len (patch 5)
- new patches: changing mtu clean up, (re)init phy on resume
- add net_ratelimit (patch 8)

All patches in series was tested on RTL8111/8168B

