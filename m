From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Extend lock less TX to real devices
Date: Sun, 05 Sep 2004 05:39:19 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1C3gNb-0006DO-00@gondolin.me.apana.org.au>
References: <20040904132809.GB33964@muc.de>
Cc: davem@redhat.com, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com,
        akepner@sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ak@muc.de (Andi Kleen)
In-Reply-To: <20040904132809.GB33964@muc.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andi Kleen <ak@muc.de> wrote:
>
>> > I added support for trylocking instead of spinning like sch_generic
>> > does - for that the driver has to return -1, then the packet is requeued.
>> > The check for a local device deadlock is lost for this case, 
>> > but that doesn't seem to be a big loss (I've never seen this printk 
>> > ever get triggered)
>> 
>> It is triggerable if you misconfigure your system.
> 
> Really? The only reason I can see for it is a buggy driver.

Is this the dead loop message? If so it can happen with tunnels.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
