From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [7/7] [IPSEC] Add XFRMA_SA/XFRMA_POLICY for delete notification
Date: Mon, 9 May 2005 07:40:49 +1000
Message-ID: <20050508214049.GA14415@gondor.apana.org.au>
References: <20050507072058.GD5753@gondor.apana.org.au> <20050507072139.GE5753@gondor.apana.org.au> <20050507072216.GF5753@gondor.apana.org.au> <20050507072251.GG5753@gondor.apana.org.au> <20050507072349.GH5753@gondor.apana.org.au> <1115467457.19561.5.camel@localhost.localdomain> <20050507122504.GA21693@gondor.apana.org.au> <1115470004.19561.49.camel@localhost.localdomain> <20050507193538.GA28991@gondor.apana.org.au> <1115560594.19561.117.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1115560594.19561.117.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, May 08, 2005 at 09:56:33AM -0400, jamal wrote:
> 
> Why would someone need to deduce whether it has been deleted by index or
> selector?

It isn't just about deducing the message.  It's about sending a delete
message in the same format as we would receive them.  As it is the
delete message sent would be not be accepted if you sent it back to the

> Does pfkey have ability to delete by index and selector?

Yes.

> If yes, how do you distinguish the two cases when you are sending the
> netlink event?

Using the byid attribute that *you* introduced :)

> > As it is the netlink delete messages sent by notification are invalid
> > by its own standard.
> 
> It doesnt seem to me what you provided in the patch produces exactly the
> same thing that was sent by user space back in the event.

That's not the point.  The point is if you send exactly the same
message to the kernel, even with the RTAs attached, the kernel
would accept it and perform the deletion if there is a matching
policy.
 
> Heres what i will say so we can put this to rest:
> The patch is unneeded (i hate to use strong words like bogus - but it is
> getting close to that), but if you feel strongly about it just lets have
> it well documented and provide the iproute2 patch as well.

I'll leave the decision up to Dave.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
