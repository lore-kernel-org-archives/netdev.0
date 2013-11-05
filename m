From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/3] net: allow to leave the buffer fragmented
 in skb_cow_data()
Date: Tue, 05 Nov 2013 06:33:15 -0800
Message-ID: <1383661995.4291.137.camel@edumazet-glaptop2.roam.corp.google.com>
References: <cover.1381923854.git.mathias.krause@secunet.com>
	 <14f30e8f5f8405c1ca73b6d3a554441c1736142d.1381923854.git.mathias.krause@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>,
	netdev@vger.kernel.org
To: Mathias Krause <mathias.krause@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:42446 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754831Ab3KEOdS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Nov 2013 09:33:18 -0500
Received: by mail-pa0-f41.google.com with SMTP id rd3so8929773pab.28
        for <netdev@vger.kernel.org>; Tue, 05 Nov 2013 06:33:17 -0800 (PST)
In-Reply-To: <14f30e8f5f8405c1ca73b6d3a554441c1736142d.1381923854.git.mathias.krause@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-11-05 at 14:54 +0100, Mathias Krause wrote:
> Do not linearize the buffer per se but only if we're expected to expand
> the tail. All callers can handle fragmented buffers and even expect
> them!
> 
> Not linearizing the buffer leads to a small performance improvement for
> the IPsec receive path in case the network driver passed us a fragmented
> buffer.
> 
> With this patch applied I was able to increase the throughput of an
> IPsec gateway from 7.12 Gbit/s to 7.28 Gbit/s.

What is the driver you used ?
