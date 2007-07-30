From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] netxen: drop redudant spinlock
Date: Mon, 30 Jul 2007 15:52:15 -0400
Message-ID: <46AE416F.1070501@garzik.org>
References: <Pine.LNX.4.64.0707272257090.27724@stellar.unminc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dhananjay Phadke <dhananjay@netxen.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48735 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966733AbXG3TwR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jul 2007 15:52:17 -0400
In-Reply-To: <Pine.LNX.4.64.0707272257090.27724@stellar.unminc.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dhananjay Phadke wrote:
> Some leftover code that makes use of adapter->lock in tx_timeout function,
> which resets the interface under this lock. In close() when the workqueue
> is flushed, prints the warning about sleeping with interrupts disabled
> (when spinlock debug is enabled). The lock was required with private netxen
> IOCTLs, which were removed a while ago.

applied


