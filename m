From: Tom Herbert <therbert@google.com>
Subject: [PATCH 0/2] net: Allow allocating different number RX and TX mqs
Date: Sun, 9 Jan 2011 21:36:25 -0800 (PST)
Message-ID: <alpine.DEB.2.00.1101092123340.3137@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:58728 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751011Ab1AJFgb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jan 2011 00:36:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add functions so that a different number of TX and RX queues can be
allocated in a netdevice.  Second patch modifies mlx4 driver to call
this function which is an example of a driver that allocates different
numbers for TX and RX queues.

