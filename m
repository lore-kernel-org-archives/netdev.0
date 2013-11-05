From: Mathias Krause <mathias.krause@secunet.com>
Subject: Re: [PATCH net-next 3/3] net: allow to leave the buffer fragmented
 in skb_cow_data()
Date: Tue, 05 Nov 2013 15:43:10 +0100
Message-ID: <527903FE.9090505@secunet.com>
References: <cover.1381923854.git.mathias.krause@secunet.com>	 <14f30e8f5f8405c1ca73b6d3a554441c1736142d.1381923854.git.mathias.krause@secunet.com> <1383661995.4291.137.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:54141 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754481Ab3KEOnO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Nov 2013 09:43:14 -0500
In-Reply-To: <1383661995.4291.137.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05.11.2013 15:33, Eric Dumazet wrote:
> On Tue, 2013-11-05 at 14:54 +0100, Mathias Krause wrote:
>> Do not linearize the buffer per se but only if we're expected to expand
>> the tail. All callers can handle fragmented buffers and even expect
>> them!
>>
>> Not linearizing the buffer leads to a small performance improvement for
>> the IPsec receive path in case the network driver passed us a fragmented
>> buffer.
>>
>> With this patch applied I was able to increase the throughput of an
>> IPsec gateway from 7.12 Gbit/s to 7.28 Gbit/s.
> 
> What is the driver you used ?

The device driver is ixgbe driving an Intel X520-T2. Why you're asking?
