From: Mathias Krause <mathias.krause@secunet.com>
Subject: Re: [PATCH net-next 1/3] net: move pskb_put() to core code
Date: Wed, 06 Nov 2013 10:01:11 +0100
Message-ID: <527A0557.2060707@secunet.com>
References: <cover.1381923854.git.mathias.krause@secunet.com>	 <5044e9be63b6e0734670654e6249576e3be4279e.1381923854.git.mathias.krause@secunet.com> <1383676424.2868.11.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>,
	netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:47910 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752555Ab3KFJBO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Nov 2013 04:01:14 -0500
In-Reply-To: <1383676424.2868.11.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05.11.2013 19:33, Ben Hutchings wrote:
> On Tue, 2013-11-05 at 14:54 +0100, Mathias Krause wrote:
>> This function has usage beside IPsec so move it to the core skbuff code.
>> While doing so, give it some documentation and change its return type to
>> 'unsigned char *' to be in line with skb_put().
> [...]
>> --- a/net/core/skbuff.c
>> +++ b/net/core/skbuff.c
>> @@ -1257,6 +1257,29 @@ free_skb:
>>  EXPORT_SYMBOL(skb_pad);
>>  
>>  /**
>> + *	pskb_put - add data to the tail of a potentially fragmented buffer
>> + *	@skb: start of the buffer to use
>> + *	@tail: tail fragment of the buffer to use
>> + *	@len: amount of data to add
>> + *
>> + *	This function extends the used data area of the potentially
>> + *	fragmented buffer. &tail must be the last fragment of &skb -- or
>> + *	&skb itself. If this would exceed the total buffer size the kernel
> 
> Keep using @ to refer to the parameters in this description.
> 
> Ben.

Thanks Ben. Looks like I looked at the wrong examples on how to do it.
Will fix those as well.

> 
>> + *	will panic. A pointer to the first byte of the extra data is
>> + *	returned.
>> + */
> [...]
> 
