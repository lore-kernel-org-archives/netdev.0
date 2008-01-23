From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.25 1/1]S2io: Multiqueue network device support implementation
Date: Tue, 22 Jan 2008 19:55:11 -0500
Message-ID: <4796906F.2010503@garzik.org>
References: <Pine.GSO.4.10.10801221942530.24414-100000@guinness>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, support@neterion.com
To: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38724 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758832AbYAWAzO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jan 2008 19:55:14 -0500
In-Reply-To: <Pine.GSO.4.10.10801221942530.24414-100000@guinness>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sreenivasa Honnur wrote:
> Multiqueue netwrok device support implementation.
> - Added a loadable parameter "multiq" to enable/disable multiqueue support,
>   by default it is disabled.
> - skb->queue_mapping is not used for queue/fifo selection. FIFO iselection is
>   based on IP-TOS value, 0x0-0xF TOS values are mapped to 8 FIFOs.
> - Added per FIFO flags FIFO_QUEUE_START and FIFO_QUEUE_STOP. Check this flag
>   for starting and stopping netif queue and update the flags accordingly.
> - In tx_intr_handler added a check to ensure that we have free TXDs before wak-
>   ing up the queue.
> - Added helper functions for queue manipulation(start/stop/wakeup) to invoke
>   appropriate netif_ functions.
> - Calling netif_start/stop for link up/down case respectively.
> 
> Signed-off-by: Surjit Reang <surjit.reang@neterion.com>
> Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>

thanks, at a quick glance, the use of the new multi-queue APIs look ok. 
  I'll give it another in-depth look and merge it.


