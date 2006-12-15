From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: dhcpclient netlink bugs (was Re: [NETLINK]: Schedule removal of old macros exported to userspace)
Date: Fri, 15 Dec 2006 11:46:50 +1100
Message-ID: <E1Gv1Du-0002B1-00@gondolin.me.apana.org.au>
References: <200612120757.24880.stefan@loplof.de>
Cc: tgraf@suug.ch, netdev@vger.kernel.org, libc-alpha@sourceware.org
Return-path: <libc-alpha-return-19699-glibc-alpha=m.gmane.org@sourceware.org>
To: stefan@loplof.de (Stefan Rompf)
In-Reply-To: <200612120757.24880.stefan@loplof.de>
List-Unsubscribe: <mailto:libc-alpha-unsubscribe-glibc-alpha=m.gmane.org@sourceware.org>
List-Subscribe: <mailto:libc-alpha-subscribe@sourceware.org>
List-Archive: <http://sourceware.org/ml/libc-alpha/>
List-Post: <mailto:libc-alpha@sourceware.org>
List-Help: <mailto:libc-alpha-help@sourceware.org>, <http://sourceware.org/ml/#faqs>
Sender: libc-alpha-owner@sourceware.org
List-Id: netdev.vger.kernel.org

Stefan Rompf <stefan@loplof.de> wrote:
>
> Yes, the code has quite some trust into the kernel that if it answers the 
> asked question the answer is semantically correct. But to be fair, if you 
> issue a write(), you also expect the number of bytes written in return and 
> not the msec taken ;-) Will fix that and the other stuff you pointed out, 
> thanks!

I hope you checked that the message is really from the kernel (based on
saddr).  Unconnected sockets can receive messages from any user on the
host.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
