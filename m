From: Stephen Hemminger <shemminger@osdl.org>
Subject: [RFC 0/7] neighbour table lockless read
Date: Mon, 14 Aug 2006 14:20:04 -0700
Message-ID: <20060814212004.606140865@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:16874 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S964959AbWHNVYn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 17:24:43 -0400
To: David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This set of patches changes the neighbour table used by ARP and
IPV6 neighbour discovery to use RCU and seqlock's. This improves
performance by eliminated locked instructions in the common
case.

--

