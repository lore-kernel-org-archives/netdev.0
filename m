From: Tom Herbert <therbert@google.com>
Subject: [PATCH 0/2] net: RX queue weights
Date: Fri, 11 Feb 2011 16:00:48 -0800 (PST)
Message-ID: <alpine.DEB.2.00.1102111551280.2659@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:48944 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756887Ab1BLAAy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Feb 2011 19:00:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds support for RX queue weights and implements
this for bnx2x driver.  This was motivated primarily by the need to
change number of receive queues after modprobe, and turning this into
a weight attribute was straightforward anyway and may have some
interesting uses.
