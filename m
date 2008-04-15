From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 0/10][VLAN]: Make VLAN devices work in net namespaces.
Date: Tue, 15 Apr 2008 15:59:27 +0400
Message-ID: <4804989F.1060503@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:36350 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757597AbYDOLZO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 07:25:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set does not intersect with the TUN one at all, since
they both use generic net pointers.

It also includes some changes in RTNL code to facilitate
VLAN netnsization and a bit more VLAN cleanups.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
