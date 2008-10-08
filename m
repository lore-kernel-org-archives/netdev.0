From: David Miller <davem@davemloft.net>
Subject: Re: myri10ge: add multiqueue TX
Date: Wed, 08 Oct 2008 16:19:05 -0700 (PDT)
Message-ID: <20081008.161905.178410582.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: brice@myri.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45959
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754416AbYJHXT3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 19:19:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Applied to net-next-2.6 after removing the bogus references to the
non-existing CONFIG_NETDEVICES_MULTIQUEUE and NETIF_F_MULTI_QUEUE.

I do have a question about this patch, why in the world do you
need to modulus the queue number in ->hard_start_xmit() when
the core is going to do that for you modulus ->real_num_tx_queues?

If it's unnecessary, remove it please, thanks.

Thanks.
