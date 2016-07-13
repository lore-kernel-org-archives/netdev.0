From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] limit sk_filter trim to payload
Date: Wed, 13 Jul 2016 11:57:20 -0700 (PDT)
Message-ID: <20160713.115720.1957329060122160316.davem@davemloft.net>
References: <1468361937-102786-1-git-send-email-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
	daniel@iogearbox.net, hannes@stressinduktion.org,
	eric.dumazet@gmail.com, willemb@google.com
To: willemdebruijn.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38768 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751276AbcGMS50 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2016 14:57:26 -0400
In-Reply-To: <1468361937-102786-1-git-send-email-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Date: Tue, 12 Jul 2016 18:18:55 -0400

> From: Willem de Bruijn <willemb@google.com>
> 
> Sockets can apply a filter to incoming packets to drop or trim them.
> Fix two codepaths that call skb_pull/__skb_pull after sk_filter
> without checking for packet length.
> 
> Reading beyond skb->tail after trimming happens in more codepaths, but
> safety of reading in the linear segment is based on minimum allocation
> size (MAX_HEADER, GRO_MAX_HEAD, ..).

Series applied and queued up for -stable, thanks.
