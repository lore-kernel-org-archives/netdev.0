From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/3]: Seperate netdev address list locking.
Date: Mon, 23 Jun 2008 20:54:09 -0700 (PDT)
Message-ID: <20080623.205409.75801733.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41037
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752549AbYFXDyJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2008 23:54:09 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id A34CCC8C1B6
	for <netdev@vger.kernel.org>; Mon, 23 Jun 2008 20:54:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The generic TX lock is overloaded to protect both
->hard_start_xmit() execution and the unicast/multicast
device lists.

These patches seperate out that usage so that the TX
lock only protects packet transmit.

This work is pretty straightforward so I will check it
directly into net-tx-2.6
