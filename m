From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 0/6][NETNS][SOCK]: Make "prot inuse" counters work
 per-net.
Date: Thu, 27 Mar 2008 11:04:27 +0300
Message-ID: <47EB550B.8070401@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Eric Dumazet <dada1@cosmosbay.com>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:40170 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753730AbYC0IEh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2008 04:04:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These counters show the number of sockets used for each protocol,
but currently they gather global statistics. This is useful to
have them work per-net.

This set adds this possibility, but hides it under CONFIG_NET_NS
option, so that not-virtualized kernel keeps using the optimized
version by Eric (and he's in Cc for that reason).

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
