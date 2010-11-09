From: Tom Herbert <therbert@google.com>
Subject: [PATCH 0/2] net: Changes in queue allocation and freeing
Date: Tue, 9 Nov 2010 12:47:26 -0800 (PST)
Message-ID: <alpine.DEB.1.00.1011091240470.18565@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:38007 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752350Ab0KIUrb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Nov 2010 15:47:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes to both RX and TX queue allocation.  In both cases allocate
in alloc_netdev_mq and free in free_netdev.  For RX the reference
couting also changed, the device reference count can now be used.
