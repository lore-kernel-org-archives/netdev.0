From: Brice Goglin <brice@myri.com>
Subject: Re: myri10ge: add multiqueue TX
Date: Thu, 09 Oct 2008 13:51:32 +0200
Message-ID: <48EDF044.4090304@myri.com>
References: <20081008.161905.178410582.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1829 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754736AbYJILuK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Oct 2008 07:50:10 -0400
In-Reply-To: <20081008.161905.178410582.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> Applied to net-next-2.6 after removing the bogus references to the
> non-existing CONFIG_NETDEVICES_MULTIQUEUE and NETIF_F_MULTI_QUEUE.
>
> I do have a question about this patch, why in the world do you
> need to modulus the queue number in ->hard_start_xmit() when
> the core is going to do that for you modulus ->real_num_tx_queues?
>   

Right, it's probably over-paranoid. We'll check things in depth and
probably remove it soon.

Brice

