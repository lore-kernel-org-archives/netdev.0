From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Wrong UIDs reported in /proc/net/tcp
Date: Fri, 19 Nov 2004 12:26:10 +1100
Message-ID: <E1CUxXO-0002td-00@gondolin.me.apana.org.au>
References: <OFC99BB8DD.C1F76875-ON88256F50.0082ECFE-88256F50.00838992@us.ibm.com>
Cc: chad@tindel.net, linux-net@vger.kernel.org, netdev@oss.sgi.com,
        netdev-bounce@oss.sgi.com, shemminger@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: dlstevens@us.ibm.com (David Stevens)
In-Reply-To: <OFC99BB8DD.C1F76875-ON88256F50.0082ECFE-88256F50.00838992@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David Stevens <dlstevens@us.ibm.com> wrote:
> 
> Might be more intuitive semantics if the first read resulted in a complete
> copy of the data at that point, fed back to the application in whatever
> chunks it wants, but only if the buffering didn't eat lots of memory.

There is no point in fixing this.  We already have a working replacement
called tcp_diag.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
