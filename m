From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [patch] devinet: cleanup if statements
Date: Thu, 23 Jun 2005 21:38:00 +1000
Message-ID: <E1DlQ1w-0003yI-00@gondolin.me.apana.org.au>
References: <20050621.134822.21926602.davem@davemloft.net>
Cc: pmeda@akamai.com, jgarzik@pobox.com, akpm@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net (David S. Miller)
In-Reply-To: <20050621.134822.21926602.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller <davem@davemloft.net> wrote:
> 
> The second hunk of your patch seems to defeat the intention
> of that code.  I believe the idea is that if the label and
> the device name differ, use the label.

Actually I think Prasanna is right.  The if conditional is testing
whether ifa->ifa_label is NULL.  As ifa->ifa_label is an array and
it's not the first element in the structure, it can't possibly be
NULL.

With your interpretation above his patch is correct as well.  If
we want to use the label when it is different from the device name,
then it is equivalent to always use the label since the only time
we'd use the device name is when it's equal to the label :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
