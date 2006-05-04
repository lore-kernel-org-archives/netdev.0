From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: latest -stable breaks Squid
Date: Fri, 5 May 2006 09:30:12 +1000
Message-ID: <20060504233012.GA31033@gondor.apana.org.au>
References: <E1FbSM8-0002lx-00@gondolin.me.apana.org.au> <4459574D.6000303@candelatech.com> <cbec11ac0605031859n5ef0babcib5f970da1ced7df7@mail.gmail.com> <20060504.162546.88959729.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: imcdnzl@gmail.com, greearb@candelatech.com, davej@redhat.com,
	netdev@vger.kernel.org, stable@vger.kernel.org,
	fedora-list@list.zikzak.de, fedoralist@kotoulas.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:51466 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932348AbWEDXaY
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 May 2006 19:30:24 -0400
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060504.162546.88959729.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 04, 2006 at 04:25:46PM -0700, David S. Miller wrote:
> 
> That being said, the first thing that should be tried is reverting
> the above mentioned change and see if the problem goes away.  If
> so, then we need to investigate what the bandwidth delay product is
> for the connection, and whether the socket send buffer is set large
> enough for that size of pipe.

I've tracked the networking breakage down to a broken Xen patch.
So 2.6.16.13 is all OK.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
