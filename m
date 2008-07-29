From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [Patch 1/1 net-next] S2io: fix statistics flush after a MTU change
Date: Tue, 29 Jul 2008 18:25:07 -0400
Message-ID: <488F98C3.8060701@garzik.org>
References: <48863498.3020902@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ram.vepa@neterion.com,
	santosh.rastapur@neterion.com, sivakumar.subramani@neterion.com,
	sreenivasa.honnur@neterion.com, Jay Vosburgh <fubar@us.ibm.com>
To: Breno Leitao <leitao@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43923 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757009AbYG2WZM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jul 2008 18:25:12 -0400
In-Reply-To: <48863498.3020902@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Breno Leitao wrote:
> On s2io driver, when you change the interface MTU, it invokes a card
> reset, which flush some statistics.  This patch solves this problem, and
> also set the net_device->stats as the default statistics structure,
> instead of s2io_nic->stats.
> 
> To do that, s2io_nic->stats turned into a staging area, where is saved
> statistics of the last hardware statistics query. So, the difference
> between the current hardware statistics and s2io_nic->stats, is the
> value that should be summed up, in order to get the correct statistics
> value, even after a reset.
> 
> Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

applied


