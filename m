From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Fw: ipsec hang
Date: Thu, 25 Nov 2004 21:22:41 +1100
Message-ID: <E1CXGlt-00069n-00@gondolin.me.apana.org.au>
References: <Xine.LNX.4.44.0411241729550.19791-100000@thoron.boston.redhat.com>
Cc: kaber@trash.net, akpm@osdl.org, netdev@oss.sgi.com, mg@iceni.pl,
        bill@crowellsystems.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jmorris@redhat.com (James Morris)
In-Reply-To: <Xine.LNX.4.44.0411241729550.19791-100000@thoron.boston.redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

James Morris <jmorris@redhat.com> wrote:
> On Wed, 24 Nov 2004, Patrick McHardy wrote:
> 
>> This patch fixes it. When a policy with a priority lower than an
>> existing policy is inserted, it loops forever on the existing policy.
> 
> I wonder if it's the same bug as 
> http://bugme.osdl.org/show_bug.cgi?id=3796

Quite likely.

Bill, can you please try the latest BK tree and see if you can
still reproduce the hang?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
