From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] bonding: Fix corrupted queue_mapping
Date: Fri, 08 Jun 2012 09:52:05 +0200
Message-ID: <1339141925.6001.51.camel@edumazet-glaptop>
References: <1339135057.6001.20.camel@edumazet-glaptop>
	 <20120607.230216.2014005732863772019.davem@davemloft.net>
	 <1339135881.6001.25.camel@edumazet-glaptop>
	 <20120607.231501.463746858434969001.davem@davemloft.net>
	 <1339138040.6001.39.camel@edumazet-glaptop>
	 <1339140238.6001.42.camel@edumazet-glaptop>  <4FD1ACE1.4050005@intel.com>
	 <1339141738.6001.49.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, therbert@google.com,
	netdev@vger.kernel.org
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:63954 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757826Ab2FHHwJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2012 03:52:09 -0400
Received: by eaak11 with SMTP id k11so845792eaa.19
        for <netdev@vger.kernel.org>; Fri, 08 Jun 2012 00:52:07 -0700 (PDT)
In-Reply-To: <1339141738.6001.49.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-06-08 at 09:49 +0200, Eric Dumazet wrote:

> Yes, it sounds like sk setting (sk->sk_tx_queue_mapping) has precedence
> over skb->queue_mapping.
> 
> Not sure how it works for UDP workload for example.

Unconnected UDP sockets dont have sk_dst_cache, so
sk->sk_tx_queue_mapping stay to -1, so everything seems good.
