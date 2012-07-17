From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] be2net: dont pull too much data in skb linear
 part
Date: Mon, 16 Jul 2012 23:03:00 -0700 (PDT)
Message-ID: <20120716.230300.2238417953321284205.davem@davemloft.net>
References: <1342185581.3265.8355.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: padmanabh.ratnakar@emulex.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46435 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754621Ab2GQGDA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 02:03:00 -0400
In-Reply-To: <1342185581.3265.8355.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 13 Jul 2012 15:19:41 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> skb_fill_rx_data() pulls 64 byte of data in skb->data
> 
> Its too much for TCP (with no options) on IPv4, as total size of headers
> is 14 + 40 = 54
> 
> This means tcp stack and splice() are suboptimal, since tcp payload
> is in part in tcp->data, and in part in skb frag.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
