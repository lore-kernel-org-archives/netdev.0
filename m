From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC 1/4] kevent: core files.
Date: Mon, 31 Jul 2006 20:35:55 +1000
Message-ID: <E1G7V7r-0006jL-00@gondolin.me.apana.org.au>
References: <20060731103322.GA1898@2ka.mipt.ru>
Cc: drepper@redhat.com, zach.brown@oracle.com, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:47632 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751507AbWGaKgW
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jul 2006 06:36:22 -0400
To: johnpol@2ka.mipt.ru (Evgeniy Polyakov)
In-Reply-To: <20060731103322.GA1898@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
>
>> - if there is space, report it in the ring buffer.  Yes, the buffer
>>   can be optional, then all events are reported by the system call.
> 
> That requires a copy, which can neglect syscall overhead.
> Do we really want it to be done?

Please note that we're talking about events here, not actual data.  So
only the event is being copied, which is presumably rather small compared
to the data.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
