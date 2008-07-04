From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 0/4] MIB: add struct net to UDP accounting macros
Date: Fri, 04 Jul 2008 15:58:44 +0400
Message-ID: <486E1074.7040702@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Denis Lunev <den@openvz.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:35755 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752581AbYGDMBR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jul 2008 08:01:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the first small set of MIB statistics netnsization. The easiest
case is UDP stats, so I started with this one. If this set is accepted,
I will go on step-by-step with adding struct net to all the other stats' 
accounting macros, then SNMP_XXX ones and finish with a set than will put 
the stats on the struct net and fix appropriate proc files.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
Acked-by: Denis V. Lunev <den@openvz.org>
