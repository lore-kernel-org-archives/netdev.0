From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Fw: [Bug 3610] New: kernel-2.6.9 breaks Amanda
Date: Fri, 22 Oct 2004 08:01:40 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1CKl08-00065S-00@gondolin.me.apana.org.au>
References: <20041021142335.54f088ad.davem@davemloft.net>
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net (David S. Miller)
In-Reply-To: <20041021142335.54f088ad.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller <davem@davemloft.net> wrote:
> 
> ChangeSet 1.1803.16.6 2004/07/21 13:51:01 Samuel.Thibault@ens-lyon.fr
> 
> I'm mostly suspicious of the latter, because it changes the
> behvaior of UDP sockets when MSG_TRUNC is specified.  Can

Well that change made it in 2.6.8.1 so if 2.6.8.1 is working for him
then that can't be it.  That change also seems to only change the
return value.

In fact, since tcpdump is showing bad checksums, then presumably
the packet has been corrupted before it even got to us.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
