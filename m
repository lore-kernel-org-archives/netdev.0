From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [patch 4/10] s390: network driver.
Date: Tue, 07 Dec 2004 12:13:33 +1100
Message-ID: <E1CbTv3-000732-00@gondolin.me.apana.org.au>
References: <200412061642.00552.hasso@estpak.ee>
Cc: hadi@cyberus.ca, paul@clubi.ie, thomas.spatzier@de.ibm.com,
        jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hasso@estpak.ee (Hasso Tepper)
In-Reply-To: <200412061642.00552.hasso@estpak.ee>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hasso Tepper <hasso@estpak.ee> wrote:
> 
> Seems that it's no longer true. Seems that kernel is now trying as hard as 
> possible not to loose any data - data is queued and if the queue will be 
> full, all related sockets will be blocked to notify application. So, one 
> socket approach don't work any more for Quagga/Zebra. No problem, we can 
> take the "one socket per interface" approach. And we already have link 
> detection implemented to notify daemons.

I don't see why this should be happening.  Can you please provide a
minimal program that reproduces this blocking problem? For example,
something that sends a packet to a downed interface and then sends
one to an interface that's up?
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
