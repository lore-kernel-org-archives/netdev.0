From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 0/6] Lockless neighbour table
Date: Mon, 28 Aug 2006 16:07:48 -0700
Message-ID: <20060828230748.827712918@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:6786 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751468AbWH1XM1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2006 19:12:27 -0400
To: David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an updated version of the changes to make the neighbour (ARP)
table lockless for normal accesses.  It uses RCU and seqlock in
several places.  I separated the hlist conversions from RCU
changes (in case we need to bisect for some reason).

--
Stephen Hemminger <shemminger@osdl.org>

