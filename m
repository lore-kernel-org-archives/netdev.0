From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 0/2 net-next] vxlan: Liberal parsing & basic VXLAN-gpe
Date: Fri, 11 Jul 2014 18:59:48 +0200
Message-ID: <cover.1405097440.git.tgraf@suug.ch>
Cc: stephen@networkplumber.org, therbert@google.com,
	nicolas.dichtel@6wind.com, pshelar@nicira.com,
	xiyou.wangcong@gmail.com, ogerlitz@mellanox.com,
	dborkman@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:39554 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751181AbaGKQ7z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2014 12:59:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series makes VXLAN receive more liberal in what it accepts.
The receive behaviour is now in accordance with the draft. It also
establishes basic support for VXLAN-gpe to allow carrying non ethernet
in the future.

Thomas Graf (2):
  vxlan: Be liberal on receive and only require the I bit to be set
  vxlan: Minimal support for Generic Protocol Extension (VXLAN-gpe)

 drivers/net/vxlan.c | 88 +++++++++++++++++++++++++++++++++++++++++++++--------
 1 file changed, 76 insertions(+), 12 deletions(-)

-- 
1.9.3
