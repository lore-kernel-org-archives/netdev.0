From: Mathias Krause <mathias.krause@secunet.com>
Subject: Re: [PATCH net-next 3/3] net: allow to leave the buffer fragmented
 in skb_cow_data()
Date: Wed, 06 Nov 2013 10:49:18 +0100
Message-ID: <527A109E.5040000@secunet.com>
References: <cover.1381923854.git.mathias.krause@secunet.com> <14f30e8f5f8405c1ca73b6d3a554441c1736142d.1381923854.git.mathias.krause@secunet.com> <20131106093028.GA18435@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:49020 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753854Ab3KFJtV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Nov 2013 04:49:21 -0500
In-Reply-To: <20131106093028.GA18435@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06.11.2013 10:30, Herbert Xu wrote:
> On Tue, Nov 05, 2013 at 02:54:11PM +0100, Mathias Krause wrote:
>> -	/* If skb is cloned or its head is paged, reallocate
>> -	 * head pulling out all the pages (pages are considered not writable
>> -	 * at the moment even if they are anonymous).
>> +	/* If skb is cloned reallocate head pulling out all the pages (pages are
>> +	 * considered not writable at the moment even if they are anonymous).
>>  	 */
> 
> Hang on, you haven't explained why it is OK to write to pages.

Why wouldn't it if the skb isn't cloned?

> What if said page is owned by the virt host or some app?

How would one detect such a case. I could image not by testing
skb_shinfo(skb)->nr_frags as it is right now?


Regards,
Mathias
