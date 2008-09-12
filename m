From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: UDP and Raw packet output not scaling with number of cores (10G, ixgbe and bnx2x)
Date: Fri, 12 Sep 2008 16:00:02 -0700
Message-ID: <E1KeHcQ-0002T8-R7@gondolin.me.apana.org.au>
References: <20080911.203450.29338239.davem@davemloft.net>
Cc: wurzel@ccpu.com, linux-net@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net (David Miller)
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <20080911.203450.29338239.davem@davemloft.net>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:
>
>> I'm not trying to do anything fancy with QOS or egress rates; basically 
>> I just want a program that does
>>       fd = socket()   // either UDP or Raw
>>       while (1)  send(fd, buf, 1024)

Please post the actual program as the current queue selection is
flow based so how you construct your sockets matter.

Also are you sure you're CPU-bound? If the bottleneck is elsewhere
then increasing threads isn't going to do anything.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
