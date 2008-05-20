From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-next 0/10] Stir up struct net_device_stats usage and whereabouts.
Date: Tue, 20 May 2008 20:27:03 +0400
Message-ID: <4832FBD7.7040209@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:37063 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932918AbYETQ3c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 May 2008 12:29:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a on-device statistics already, so those drivers, that
needs some statistics, may use this one. This set relaxes bridge, 
tunnels and mr devices thus, making them occupy less memory.

Besides, the get_stats pointer and the pointer it returns are no
longer NULL, while there are still some places, that check for this.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
