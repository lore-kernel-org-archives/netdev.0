From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/4] inet: Add skb_copy_datagram_iter
Date: Sat, 8 Nov 2014 10:21:21 +0800
Message-ID: <20141108022121.GA25900@gondor.apana.org.au>
References: <20141105210745.GT7996@ZenIV.linux.org.uk>
 <20141105.165719.835728206041332333.davem@davemloft.net>
 <20141106032533.GU7996@ZenIV.linux.org.uk>
 <20141107.164859.951682597018909290.davem@redhat.com>
 <20141107221114.GB7996@ZenIV.linux.org.uk>
 <20141107234253.GE7996@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, bcrl@kvack.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141107234253.GE7996@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 07, 2014 at 11:42:53PM +0000, Al Viro wrote:
> I'll finish RTFS drivers/vhost and if it turns out to be OK I'll post the
> series moving those checks to the moment of copying iovec from userland,
> so that kernel-side we could always rely on ->msg_iov elements having been
> verified.

Great thanks!

Dave, please hold off on my skb_copy_datagram_iter series until
this verify_iovec change is added.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
