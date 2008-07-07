From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-next 0/7] MIB: add struct net to ICMP accounting macros
Date: Mon, 07 Jul 2008 14:41:28 +0400
Message-ID: <4871F2D8.8030502@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:53987 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752666AbYGGKoB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jul 2008 06:44:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Step #2. This is almost as easy as the UDP case, but requires
some preparation to have a struct net at hands in some places.

David, there are (mainly) NET, TCP and IP(6) stats left and I
planned to send them step-by-step with small series (and plus the
closing one with SNMP_XXX macros, etc). But if you prefer seeing
one large set instead of several small ones just let me know ;)

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
