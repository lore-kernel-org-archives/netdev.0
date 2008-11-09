From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 0/2] dsa: two bugfixes
Date: Mon, 10 Nov 2008 00:22:44 +0100
Message-ID: <20081109232244.GC32552@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:54000 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756432AbYKIXWq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Nov 2008 18:22:46 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Two more bugfixes for the DSA driver.  One fixes the case where a
slave interface has a MAC address different from that of the master
interface (in which case received packets would be sent up the stack
as PACKET_OTHERHOST even if they were destined to the slave
interface's MAC address), and one fixes the fact that the dsa driver
currently does not touch the master interface's allmulti/promisc
counts when a slave interface that has ALLMULTI or PROMISC set is
brought up or down.

Please apply for 2.6.28, thanks!
