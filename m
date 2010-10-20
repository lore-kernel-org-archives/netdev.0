From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] net: RX and TX queue allocation cleanup
Date: Wed, 20 Oct 2010 02:38:32 -0700 (PDT)
Message-ID: <20101020.023832.183060328.davem@davemloft.net>
References: <alpine.DEB.1.00.1010181053200.15812@pokey.mtv.corp.google.com>
	<20101020.023041.112586469.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	bhutchings@solarflare.com
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35906
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752446Ab0JTJiJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Oct 2010 05:38:09 -0400
In-Reply-To: <20101020.023041.112586469.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 20 Oct 2010 02:30:41 -0700 (PDT)

> From: Tom Herbert <therbert@google.com>
> Date: Mon, 18 Oct 2010 11:02:06 -0700 (PDT)
> 
>> Move TX queue allocation to register_netdevice.  Enforce
>> alloc_netdev_mq & netif_set_real_num_[rt]x_queues netif_alloc_rx_queues
>> are called with at least one queue to allocate.
> 
> All applied, and I fixed the indentation issue Eric noticed
> while integrating.

Just to be clear, I did make sure I used the "v2" series
of the patches, not the original. :-)

